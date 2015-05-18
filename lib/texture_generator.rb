require 'RMagick'

#must give card image_path = 'images/dark_magician.bmp'
class TextureGenerator
  def initialize(card)
    @card = card
    @image = Magick::Image.read("images/bases/#{@card.attribute.downcase}_base.bmp").first
  end

  def generate
    self.class.instance_methods(false).select do |method|
      method.match(/add_.+/)
    end.each { |method| send(method) }

    @image
  end

  def add_picture
    picture = Magick::Image.read(@card.image_path).first.scale(244, 247)
    @image.composite!(picture, 50, 110, Magick::OverCompositeOp)
  end

  def add_attribute

  end
end