require 'nokogiri'
require 'open-uri'
require_relative 'external_pages/main_page'
require_relative 'external_pages/gallery_page'
require_relative 'external_pages/card_table'

class CardDataFetcher
  YUGIOH_WIKIA_URL = 'http://yugioh.wikia.com'

  class << self
    def fetch(card_name)
      main_page = ExternalPages::MainPage.new(card_name)
      image_paths = (main_page.gallery_page.yugioh_com_urls + main_page.gallery_page.tag_force_urls).uniq.map do |image_url|
        image_name = image_url.split('/').last
        image_path = File.join(ENVIRONMENT_CONFIG['image_folder'], image_name)
        download(image_url, image_path)
        image_path
      end

      create_records(main_page, image_paths)
    end

    private
    def create_records(main_page, image_paths)
      card_number = main_page.row_value('Card Number').nil? ? nil : main_page.row_value('Card Number').to_i
      card_effect_types = main_page.row_value('Card effect types').nil? ? [] : main_page.row_value('Card effect types').split("\n").map(&:strip).uniq

      card_create_params = {
          name: main_page.row_value('English'),
          description: main_page.get_description,
          number: card_number,
          effect_types: card_effect_types
      }

      ActiveRecord::Base.transaction do
        card = Card.create!(card_create_params)
        artwork_params_list = image_paths.map {|image_path| {image_path: image_path} }
        card.artworks.create!(artwork_params_list)

        card_type = main_page.row_value('Type')

        unless ['Spell', 'Trap'].include?(card_type)
          types = main_page.row_value('Types').nil? ? [main_page.row_value('Type')] : main_page.row_value('Types').split("/").map(&:strip).uniq

          monster_create_params = {
              elemental_attribute: main_page.row_value('Attribute'),
              level: main_page.row_value('Level'),
              rank: main_page.row_value('Rank'),
              types: types,
              materials: main_page.row_value('Materials'),
              attack: main_page.row_value('ATK/DEF').split('/').first,
              defense: main_page.row_value('ATK/DEF').split('/').last,
          }

          Monster.create!(monster_create_params.merge(card: card))
        else
          non_monster_create_params = {
              property: main_page.row_value('Property'),
          }
          card_type.constantize.create()
        end
      end
    end

    def download(url, path)
      File.open(path, 'wb') do |file|
        file.write(open(url).read)
      end
    end
  end
end
