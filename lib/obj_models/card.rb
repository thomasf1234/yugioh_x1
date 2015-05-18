require_relative '../obj_model'

class Card #< ObjModel
  attr_reader :name, :card_number, :description, :image_path
end