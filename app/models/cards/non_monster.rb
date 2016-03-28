require_relative '../card'

class NonMonster < ActiveRecord::Base
  belongs_to :card

  delegate :name, :number, :description, :effect_types, :image_path, :artworks, to: :card
end