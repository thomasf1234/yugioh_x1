require_relative '../monster'

class CelticGuardian < Monster
  def name
    'Celtic Guardian'
  end

  def card_number
    91152256
  end

  def description
    <<EOF
An elf who learned to wield a sword, he baffles enemies with lightning-swift attacks.
EOF
  end

  def attribute
    'EARTH'
  end

  def type
    'Warrior'
  end

  def level
    4
  end

  def attack
    1400
  end

  def defense
    1200
  end

  #def summoning_condition
  #  !player.summon_limit_reached? && player.monsters.count >= 2
  #end
end