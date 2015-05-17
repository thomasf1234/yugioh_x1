require_relative '../card'

class Monster < Card
  attr_accessor :attribute, :type, :level, :attack, :defense

  def summoning_condition
    raise NotImplementedError.new("Subclasses must implement #{__method__}")
  end
end