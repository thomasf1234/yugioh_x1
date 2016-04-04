module ExternalPages
  class GalleryPage
    TAG_FORCE_REGEX = /TF(0\d|S)-JP-VG(-\d)?\./

    def initialize(page)
      @page = page
    end

    def tag_force_urls
      image_elements = @page.xpath("//div[@id='mw-content-text']").xpath(".//img[@class='thumbimage']")

      image_elements.inject([]) do |image_urls, image_element|
        image_url = image_element.attribute('src').value
        image_urls << image_url.split('/revision').first if image_url.match(TAG_FORCE_REGEX)
        image_urls
      end
    end

    def yugioh_com_urls
      @page.xpath("//div[@class='wikia-gallery-item']").inject([]) do |image_urls, wikia_gallery_item|
        if !wikia_gallery_item.xpath(".//a[text()='Yugioh.com']").empty?
          image_url = wikia_gallery_item.xpath(".//img[@class='thumbimage']").attribute('src').value
          image_urls << image_url.split('/revision').first
        end

        image_urls
      end
    end
  end
end


