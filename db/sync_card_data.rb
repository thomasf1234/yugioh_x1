require 'nokogiri'
require_relative 'external_pages/main_page'
require_relative 'external_pages/gallery_page'
require_relative 'external_pages/card_table'
require_relative '../lib/utilities'

class SyncCardData
  YUGIOH_WIKIA_URL = 'http://yugioh.wikia.com'

  class << self
    include Utilities

    def perform(card_name)
      ActiveRecord::Base.transaction do
        begin
          main_page = ExternalPages::MainPage.new(card_name)
          image_paths = (main_page.gallery_page.yugioh_com_urls + main_page.gallery_page.tag_force_urls).uniq.map do |image_url|
            image_name = image_url.split('/').last
            image_path = File.join(ENVIRONMENT_CONFIG['image_folder'], image_name)
            download(image_url, image_path) unless File.exists?(image_path)
            image_path
          end

          old_card = Card.find_by_name(main_page.row_value('English'))
          old_card.destroy unless old_card.nil?

          card = create_card(main_page)
          artwork_params_list = image_paths.map { |image_path| {image_path: image_path} }
          card.artworks.create!(artwork_params_list)

          log <<EOF
status: [SUCCESS]
card_name: [#{card_name}]
card_id - #{card.id}
EOF
        rescue => e
          log <<EOF
status: [FAILURE]
card_name: [#{card_name}]
 - #{e.class.name} : #{e.message}
#{e.backtrace.join("\n")}
EOF
          raise ActiveRecord::Rollback
        end
      end
    end

    private
    def create_card(main_page)
      card = Card.create!({name: main_page.row_value('English'),
                           description: main_page.get_description,
                           serial_number: main_page.row_value('Card Number'),
                           category: card_type(main_page)})

      card_effect_types = main_page.row_value('Card effect types').nil? ? [] : main_page.row_value('Card effect types').split("\n").map(&:strip)
      card_effect_types.each do |card_effect_type|
        const = CardEffects.constants.detect { |constant| constant.to_s == card_effect_type }
        CardEffects.const_get(const).create!(card_id: card.id)
      end

      properties = case card_type(main_page)
                     when Card::Types::NORMAL
                       [
                           Property.new({name: Property::Names::ELEMENT, value: main_page.row_value('Attribute'), data_type: 'string'}),
                           Property.new({name: Property::Names::LEVEL, value: main_page.row_value('Level'), data_type: 'integer'}),
                           Property.new({name: Property::Names::ATTACK, value: main_page.row_value('ATK/DEF').split('/').first, data_type: 'string'}),
                           Property.new({name: Property::Names::DEFENSE, value: main_page.row_value('ATK/DEF').split('/').last, data_type: 'string'}),
                           Property.new({name: Property::Names::SPECIES, value: main_page.row_value('Type'), data_type: 'string'}),
                       ]
                     when Card::Types::SPELL || Card::Types::TRAP
                       [
                           Property.new({name: Property::Names::PROPERTY, value: main_page.row_value('Property'), data_type: 'string'}),
                       ]
                     when Card::Types::XYZ
                       [
                           Property.new({name: Property::Names::ELEMENT, value: main_page.row_value('Attribute'), data_type: 'string'}),
                           Property.new({name: Property::Names::RANK, value: main_page.row_value('Rank'), data_type: 'integer'}),
                           Property.new({name: Property::Names::ATTACK, value: main_page.row_value('ATK/DEF').split('/').first, data_type: 'string'}),
                           Property.new({name: Property::Names::DEFENSE, value: main_page.row_value('ATK/DEF').split('/').last, data_type: 'string'}),
                           Property.new({name: Property::Names::SPECIES, value: main_page.row_value('Types').split('/').first, data_type: 'string'}),
                       ]
                     else
                       [
                           Property.new({name: Property::Names::ELEMENT, value: main_page.row_value('Attribute'), data_type: 'string'}),
                           Property.new({name: Property::Names::LEVEL, value: main_page.row_value('Level'), data_type: 'integer'}),
                           Property.new({name: Property::Names::ATTACK, value: main_page.row_value('ATK/DEF').split('/').first, data_type: 'string'}),
                           Property.new({name: Property::Names::DEFENSE, value: main_page.row_value('ATK/DEF').split('/').last, data_type: 'string'}),
                           Property.new({name: Property::Names::SPECIES, value: main_page.row_value('Types').split('/').first, data_type: 'string'}),
                       ]
                   end
      card.properties = properties
      card
    end

    def card_type(main_page)
      if ['Spell Card', 'Trap Card'].include?(main_page.row_value('Type'))
        main_page.row_value('Type').split.first
      elsif main_page.row_value('Types').nil? || (Card::Types::ALL & main_page.row_value('Types').split('/')).empty?
        Card::Types::NORMAL
      else
        common_types = Card::Types::ALL & main_page.row_value('Types').split('/')
        case common_types.count
          when 1
            common_types.first
          when 2
            non_effects = common_types - [Card::Types::EFFECT]
            case non_effects.count
              when 1
                non_effects.first
              else
                raise 'No card_type'
            end
          else
            raise 'No card_type'
        end
      end
    end

    def download(url, path)
      File.open(path, 'wb') do |file|
        file.write(retry_open(url).read)
      end
    end

    def log(string)
      File.open("log/sync_card_#{ENV['ENV']}.log", 'a+') do |file|
        file.write <<EOF
#############################################################
Time: #{DateTime.now.utc.to_s}
#{string}
#############################################################
EOF
      end
    end
  end
end
