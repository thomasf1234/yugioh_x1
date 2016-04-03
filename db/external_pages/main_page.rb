require 'nokogiri'
require_relative '../../lib/utilities'

module ExternalPages
  YUGIOH_WIKIA_URL = 'http://yugioh.wikia.com'

  class MainPage
    include Utilities

    delegate :row_value, :get_description, to: :card_table

    attr_reader :gallery_page, :card_table

    def initialize(card_name)
      @page = Nokogiri::HTML(retry_open("#{ExternalPages::YUGIOH_WIKIA_URL}/wiki/#{card_name}"))
      @card_table = CardTable.new(@page.xpath("//table[@class='cardtable']"))
    end

    def gallery_page
      gallery_end_point = @page.xpath("//td[@id='cardtablelinks']").xpath("./a[contains(@title,'Card Gallery')]").attribute('href').value.strip
      @gallery_page ||= GalleryPage.new(Nokogiri::HTML(retry_open(YUGIOH_WIKIA_URL + gallery_end_point)))
    end
  end
end


