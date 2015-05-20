class Player
  attr_accessor :hand, :deck, :life_points, :name

  def initialize(name, deck)
    @name = name
    @deck = deck
    @hand = []
  end

  def draw
    throw(:duel_end, "player '#{name}' LOST; ran out of cards") if @deck.empty?
    @hand << @deck.shift
  end

  def shuffle!(sym)
    send(sym).shuffle!
  end
end