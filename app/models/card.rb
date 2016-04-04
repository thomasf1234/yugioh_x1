require 'active_support/core_ext/module/delegation'

class Card < ActiveRecord::Base
  module Categories
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

  has_many :artworks, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :card_effects, dependent: :destroy

  validates_presence_of :name, :description
end