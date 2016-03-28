require 'active_support/core_ext/module/delegation'

class Card < ActiveRecord::Base
  has_many :artworks

  serialize :effect_types, Array

  validates_presence_of :name, :description
end