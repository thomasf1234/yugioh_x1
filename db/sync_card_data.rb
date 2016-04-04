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
      $log_file.puts '*' * 50

      ActiveRecord::Base.transaction do
        begin
          main_page = ExternalPages::MainPage.new(card_name)

          if main_page.row_value('Card Number').nil?
            $log_file.puts "Not Syncing: no serial number for #[#{card_name}]", :yellow
            $log_file.puts '*' * 50
          end

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


          $log_file.puts "Successfully synced #[#{card_name}]", :green
          $log_file.puts "card_id: #{card.id}"
          $log_file.puts '*' * 50
        rescue => e
          $log_file.puts "Failed to sync #[#{card_name}]", :red
          $log_file.puts "Exception details #{e.class} : #{e.message}"
          $log_file.puts e.backtrace.join("\n")
          $log_file.puts '*' * 50

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

      card_type = card_type(main_page)

      properties = case card_type
                     when Card::Categories::NORMAL
                       types = main_page.row_value('Types').nil? ? [main_page.row_value('Type')] : main_page.row_value('Types').split('/')
                       [
                           Property.new({name: Property::Names::ELEMENT, value: main_page.row_value('Attribute')}),
                           Property.new({name: Property::Names::LEVEL, value: main_page.row_value('Level')}),
                           Property.new({name: Property::Names::ATTACK, value: main_page.row_value('ATK/DEF').split('/').first}),
                           Property.new({name: Property::Names::DEFENSE, value: main_page.row_value('ATK/DEF').split('/').last}),
                           Property.new({name: Property::Names::SPECIES, value: species(types)}),
                       ]
                     when Card::Categories::SPELL
                       [
                           Property.new({name: Property::Names::PROPERTY, value: main_page.row_value('Property')}),
                       ]
                     when Card::Categories::TRAP
                       [
                           Property.new({name: Property::Names::PROPERTY, value: main_page.row_value('Property')}),
                       ]
                     when Card::Categories::XYZ
                       [
                           Property.new({name: Property::Names::ELEMENT, value: main_page.row_value('Attribute')}),
                           Property.new({name: Property::Names::RANK, value: main_page.row_value('Rank')}),
                           Property.new({name: Property::Names::ATTACK, value: main_page.row_value('ATK/DEF').split('/').first}),
                           Property.new({name: Property::Names::DEFENSE, value: main_page.row_value('ATK/DEF').split('/').last}),
                           Property.new({name: Property::Names::SPECIES, value: species(main_page.row_value('Types').split('/'))}),
                       ]
                     else
                       [
                           Property.new({name: Property::Names::ELEMENT, value: main_page.row_value('Attribute')}),
                           Property.new({name: Property::Names::LEVEL, value: main_page.row_value('Level')}),
                           Property.new({name: Property::Names::ATTACK, value: main_page.row_value('ATK/DEF').split('/').first}),
                           Property.new({name: Property::Names::DEFENSE, value: main_page.row_value('ATK/DEF').split('/').last}),
                           Property.new({name: Property::Names::SPECIES, value: species(main_page.row_value('Types').split('/'))}),
                       ]
                   end

      unless [Card::Categories::SPELL, Card::Categories::TRAP].include?(card_type) || main_page.row_value('Types').nil?
        abilities = (main_page.row_value('Types').split('/').map(&:strip) & Monster::Abilities::ALL)
        properties += abilities.map {|ability| Property.new({name: Property::Names::ABILITY, value: ability})}
      end

      card.properties = properties
      card
    end

    def card_type(main_page)
      if ['Spell Card', 'Trap Card'].include?(main_page.row_value('Type'))
        main_page.row_value('Type').split.first
      elsif main_page.row_value('Types').nil? || (Card::Categories::ALL & main_page.row_value('Types').split('/')).empty?
        Card::Categories::NORMAL
      else
        common_types = Card::Categories::ALL & main_page.row_value('Types').split('/')
        case common_types.count
          when 1
            common_types.first
          when 2
            non_effects = common_types - [Card::Categories::EFFECT]
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

    def species(types)
      potential = types & Monster::Species::ALL
      case potential.count
        when 1
          potential.first
        else
          raise 'No Valid Species'
      end
    end

    def download(url, path)
      File.open(path, 'wb') do |file|
        file.write(retry_open(url).read)
      end
    end
  end
end
