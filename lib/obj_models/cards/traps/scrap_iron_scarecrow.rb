require_relative '../trap'

class ScrapIronScarecrow < Trap
  def name
    'Scrap-Iron Scarecrow'
  end

  def card_number
    98427577
  end

  def description
    <<EOF
When an opponent's monster declares an attack: Target the attacking monster; negate the attack, also, after that, Set this card face-down instead of sending it to the Graveyard.
EOF
  end

  def image_path
    'images/scrap_iron_scarecrow'
  end

  def card_effect_types
    #Activation requirement, Effect
  end
end