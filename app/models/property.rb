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

  validates :name, presence: true, inclusion: { in: Names::ALL }
  validates :value, presence: true, inclusion: { in: Monster::Species::ALL }, :if => lambda { |property| property[:name] == Names::SPECIES }
  validates :value, presence: true, inclusion: { in: Monster::Abilities::ALL }, :if => lambda { |property| property[:name] == Names::ABILITY }
  validates :value, presence: true, inclusion: { in: NonMonster::Properties::ALL }, :if => lambda { |property| property[:name] == Names::PROPERTY }
end