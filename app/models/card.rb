require 'active_support/core_ext/module/delegation'

class Card < ActiveRecord::Base
  module Types
    NORMAL = 'Normal'
    EFFECT = 'Effect'
    FUSION = 'Fusion'
    RITUAL = 'Ritual'
    SYNCHRO = 'Synchro'
    XYZ = 'Xyz'
    SPELL = 'Spell'
    TRAP = 'Trap'
    ALL = constants.collect { |const| module_eval(const.to_s) }
  end

  has_many :artworks
  has_many :properties
  has_many :card_effects

  validates_presence_of :name, :description
end