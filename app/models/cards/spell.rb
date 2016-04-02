require_relative '../card'

class Spell < Card
  [:spell_trap_type].each do |method|
    define_method(method) do
      properties.find_by_name(method.to_s).value
    end
  end
end