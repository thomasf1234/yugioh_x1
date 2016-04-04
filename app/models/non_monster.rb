class NonMonster < ActiveRecord::Base
  module Properties
    NORMAL = 'Normal'
    CONTINUOUS = 'Continuous'
    FIELD = 'Field'
    EQUIP = 'Equip'
    QUICK_PLAY = 'Quick-Play'
    RITUAL = 'Ritual'
    COUNTER = 'Counter'
    ALL = constants.collect { |const| module_eval(const.to_s) }
  end

  self.primary_key = 'card_id'

  has_many :artworks, foreign_key: 'card_id'
  has_many :card_effects, foreign_key: 'card_id'

  after_initialize :readonly!
end