class Artwork < ActiveRecord::Base
  belongs_to :card

  validates_presence_of :image_path

  def transform
    image = Magick::Image.read(image_path).first
    image.contrast_stretch_channel(Magick::QuantumRange * 0.09).modulate(1.0, 1.1, 1.0).gaussian_blur(0.0, 0.5).write("tmp/transformed_#{image_name}")
  end
end