require_relative '../card'

class NonMonster < ActiveRecord::Base
  belongs_to :card
end