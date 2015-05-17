require_relative '../monster'

class GiantSoldierOfStone < Monster
  def name
    'Giant Soldier of Stone'
  end

  def card_number
    13039848
  end

  def description
    <<EOF
A giant warrior made of stone. A punch from this creature has earth-shaking results.
EOF
  end

  def attribute
    'EARTH'
  end

  def type
    'Rock'
  end

  def level
    3
  end

  def attack
    1300
  end

  def defense
    2000
  end

  #def summoning_condition
  #  !player.summon_limit_reached? && player.monsters.count >= 2
  #end
end