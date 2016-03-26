require 'nokogiri'
require 'open-uri'

class CardDataFetcher
  def fetch(card_name)
    page = Nokogiri::HTML(open("http://yugioh.wikia.com/wiki/#{card_name}"))

    table = page.xpath("//table[@class='cardtable']")
    rows = table.xpath("./tr[@class='cardtablerow']")

    map = {
        name: row_value(rows, 'English'),
        attribute: row_value(rows, 'Attribute'),
        types: row_value(rows, 'Types'),
        level: row_value(rows, 'Level'),
        attack: row_value(rows, 'ATK/DEF').split('/').first,
        defense: row_value(rows, 'ATK/DEF').split('/').last,
        description: get_description(rows),
        card_number: row_value(rows, 'Card Number'),
        materials: row_value(rows, 'Materials'),
        card_effect_types: row_value(rows, 'Card effect types')
    }

    # print(map)
  end

  private
  def row_value(rows, header)
    begin
      rows.detect do |row|
        row.xpath("./th").text.strip == header
      end.xpath("./td").text.strip
    rescue
    end
  end

  def get_description(rows)
    row = rows.detect { |row| !row.xpath(".//b[text()='Card descriptions']").empty? }
    child = row.children.first.children.detect { |child| !child.xpath(".//div[text()='English']").empty? }
    child.xpath(".//td[@class='navbox-list']").text
  end

  def print(map)
    puts "#######################"
    map.each {|k,v| puts "#{k}: #{v}\n"}
    puts "#######################"
  end
end