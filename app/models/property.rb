class Property < ActiveRecord::Base
  module Names
    ELEMENT = 'element'
    LEVEL = 'level'
    RANK = 'rank'
    SPECIES = 'species'
    ATTACK = 'attack'
    DEFENSE = 'defense'
    PROPERTY = 'property'
    ABILITY = 'ability'
    ALL = constants.collect { |const| module_eval(const.to_s) }
  end

  belongs_to :card

  validates_presence_of :name, :value
end