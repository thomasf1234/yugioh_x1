require_relative '../card'

class Trap < Card
  def attribute
    'TRAP'
  end

  def type
    'Normal'
  end

  def activation_condition
    raise NotImplementedError.new("Subclasses must implement #{__method__}")
  end
end