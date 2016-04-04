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
  [
      {name: Names::ELEMENT, set: Monster::Elements::ALL},
      {name: Names::SPECIES, set: Monster::Species::ALL},
      {name: Names::ABILITY, set: Monster::Abilities::ALL},
      {name: Names::PROPERTY, set: NonMonster::Properties::ALL},
  ].each do |params|
    validates :value, presence: true, inclusion: { in: params[:set]}, :if => lambda { |property| property[:name] == params[:name] }
  end
end