require_relative '../card'

class Effect < Card
  [:element, :level, :species, :attack, :defense].each do |method|
    define_method(method) do
      properties.find_by_name(method.to_s).value
    end
  end

  def monster_abilities
    properties.where(name: 'monster_abilites')
  end
end