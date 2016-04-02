class NonMonster < ActiveRecord::Base
  self.primary_key = 'card_id'

  has_many :artworks, foreign_key: 'card_id'
  has_many :card_effects, foreign_key: 'card_id'

  after_initialize :readonly!
end