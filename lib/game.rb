class Game
  def start
    deck1 = Deck.new([DarkMagician.new, CelticGuardian.new, GiantSoldierOfStone.new])
    deck2 = Deck.new([CelticGuardian.new, CelticGuardian.new, CelticGuardian.new, GiantSoldierOfStone.new])
    player1 = Player.new('Yugi', deck1)
    player2 = Player.new('Seto', deck2)
    game = Duel.new([player1, player2])
    game.start
  end
end