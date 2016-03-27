require 'nokogiri'
require 'open-uri'

class CardDataFetcher
  YUGIOH_WIKIA_URL = 'http://yugioh.wikia.com'

  def initialize
    @url = YUGIOH_WIKIA_URL
  end

  def fetch(card_name)
    page = Nokogiri::HTML(open("#{@url}/wiki/#{card_name}"))

    create_records(page)
    # gallery_page = Nokogiri::HTML(open(@url + gallery_end_point(page)))
  end

  private
  def fetch_yugioh_pic(gallery_page)
    image_url = image_url(gallery_page)
    image_name = image_url.split('/').last
    image_path = 'tmp/' + image_name
    download(image_url, image_path)
    # image = Magick::Image.read(image_path).first
    # image.contrast_stretch_channel(Magick::QuantumRange * 0.09).modulate(1.0, 1.1, 1.0).gaussian_blur(0.0, 0.5).write("tmp/transformed_#{image_name}")
  end

  def create_records(page)
    table = page.xpath("//table[@class='cardtable']")
    rows = table.xpath("./tr[@class='cardtablerow']")
    card_number = row_value(rows, 'Card Number').nil? ? nil : row_value(rows, 'Card Number').to_i
    card_effect_types = row_value(rows, 'Card effect types').nil? ? [] : row_value(rows, 'Card effect types').split("\n").map(&:strip).uniq

    card_create_params = {
        name: row_value(rows, 'English'),
        description: get_description(rows),
        number: card_number,
        effect_types: card_effect_types
    }

    ActiveRecord::Base.transaction do
      card_type = row_value(rows, 'Type')

      unless ['Spell', 'Trap'].include?(card_type)
        types = row_value(rows, 'Types').nil? ? [row_value(rows, 'Type')] : row_value(rows, 'Types').split("/").map(&:strip).uniq

        monster_create_params = {
            elemental_attribute: row_value(rows, 'Attribute'),
            level: row_value(rows, 'Level'),
            rank: row_value(rows, 'Rank'),
            types: types,
            materials: row_value(rows, 'Materials'),
            attack: row_value(rows, 'ATK/DEF').split('/').first,
            defense: row_value(rows, 'ATK/DEF').split('/').last,
        }
        card = Card.create!(card_create_params)
        Monster.create!(monster_create_params.merge(card: card))
      else
        non_monster_create_params = {
            property: row_value(rows, 'Property'),
        }
        card_type.constantize.create()
      end
    end
  end

  def row_value(rows, header)
    begin
      rows.detect do |row|
        row.xpath("./th").text.strip == header
      end.xpath("./td").text.strip
    rescue
    end
  end

  def get_description(rows)
    begin
      row = rows.detect { |row| !row.xpath(".//b[text()='Card descriptions']").empty? }
      child = row.children.first.children.detect { |child| !child.xpath(".//div[text()='English']").empty? }
      child.xpath(".//td[@class='navbox-list']").children.inject('') do |result, description_segment|
        result += (description_segment.name == 'br') ? "\n" : description_segment.text
        result
      end.strip
    rescue
    end
  end

  def gallery_end_point(page)
    page.xpath("//td[@id='cardtablelinks']").xpath("./a[contains(@title,'Card Gallery')]").attribute('href').value.strip
  end

  def image_url(gallery_page)
    gallery_page.xpath("//div[@class='wikia-gallery-item']").detect do |wikia_gallery_item|
      !wikia_gallery_item.xpath(".//a[text()='Yugioh.com']").empty?
    end.xpath(".//img[@class='thumbimage']").attribute('src').value.split('/revision').first
  end

  def download(url, path)
    File.open(path, 'wb') do |file|
      file.write open(url).read
    end
  end

  def print(map)
    puts "#######################"
    map.each {|k,v| puts "#{k}: #{v}\n"}
    puts "#######################"
  end
end

def get_stub(cn)
  File.open("spec/samples/db/card_data_fetcher/stubs/#{cn}" 'w+') {|f| f.write(open("#http://yugioh.wikia.com/wiki/#{cn}").read)}
end

def get_data

end

def format_data

end

def save_data

end