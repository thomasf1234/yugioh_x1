require_relative '../card'

class Monster < ActiveRecord::Base
  belongs_to :card

  serialize :types, Array

  delegate :name, :number, :description, :effect_types, :image_path, :artworks, to: :card
end