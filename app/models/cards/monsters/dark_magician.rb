require_relative '../monster'

class DarkMagician < Monster
  def name
    'Dark Magician'
  end

  def card_number
    46986414
  end

  def description
    <<EOF
The ultimate wizard in terms of attack and defense.
EOF
  end

  def attribute
    'DARK'
  end

  def type
    'Spellcaster'
  end

  def level
    7
  end

  def attack
    2500
  end

  def defense
    2100
  end

  #def summoning_condition
  #  !player.summon_limit_reached? && player.monsters.count >= 2
  #end

  def summon

  end
end