module ExternalPages
  class CardTable
    def initialize(card_table)
      @card_table = card_table
      @rows = @card_table.xpath("./tr[@class='cardtablerow']")
    end

    def row_value(header)
      begin
        @rows.detect do |row|
          row.xpath("./th").text.strip == header
        end.xpath("./td").text.strip
      rescue
      end
    end

    def get_description
      row = @rows.detect { |row| !row.xpath(".//b[text()='Card descriptions']").empty? }
      child = row.children.first.children.detect { |child| !child.xpath(".//div[text()='English']").empty? }
      child.xpath(".//td[@class='navbox-list']").children.inject('') do |result, description_segment|
        result += (description_segment.name == 'br') ? "\n" : description_segment.text
        result
      end.strip
    end
  end
end


