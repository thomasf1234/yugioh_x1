class Monster < ActiveRecord::Base
  module Elements
    DARK = 'DARK'
    DIVINE = 'DIVINE'
    EARTH = 'EARTH'
    FIRE = 'FIRE'
    LIGHT = 'LIGHT'
    WATER = 'WATER'
    WIND = 'WIND'
    ALL = constants.collect { |const| module_eval(const.to_s) }
  end

  module Species
    AQUA = 'Aqua'
    BEAST = 'Beast'
    BEAST_WARRIOR = 'Beast-Warrior'
    CREATOR_GOD = 'Creator God'
    DINOSAUR = 'Dinosaur'
    DIVINE_BEAST = 'Divine-Beast'
    DRAGON = 'Dragon'
    FAIRY = 'Fairy'
    FIEND = 'Fiend'
    FISH = 'Fish'
    INSECT = 'Insect'
    MACHINE = 'Machine'
    PLANT = 'Plant'
    PSYCHIC = 'Psychic'
    PYRO = 'Pyro'
    REPTILE = 'Reptile'
    ROCK = 'Rock'
    SEA_SERPENT = 'Sea Serpent'
    SPELLCASTER = 'Spellcaster'
    THUNDER = 'Thunder'
    WARRIOR = 'Warrior'
    WINGED_BEAST = 'Winged Beast'
    WYRM = 'Wyrm'
    ZOMBIE = 'Zombie'
    ALL = constants.collect { |const| module_eval(const.to_s) }
  end

  module Abilities
    TUNER = 'Tuner'
    GEMINI = 'Gemini'
    SPIRIT = 'Spirit'
    UNION = 'Union'
    TOON = 'Toon'
    ALL = constants.collect { |const| module_eval(const.to_s) }
  end

  self.primary_key = 'card_id'

  has_many :artworks, foreign_key: 'card_id'
  has_many :card_effects, foreign_key: 'card_id'
  has_many :abilities, -> { where(name: Property::Names::ABILITY) }, class_name: 'Property', foreign_key: 'card_id'

  after_initialize :readonly!
end