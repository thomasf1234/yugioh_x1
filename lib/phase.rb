class Phase
  attr_reader :player

  def initialize(player)
    @player = player
  end

  def run_hooks
    interact
    on_start
  end

  def interact
    while true do
      puts "turn: #{Game.current.turn}, player: #{player.name}, phase: #{self.class.name}"
      puts "options: 'hand', 'deck', 'next', 'exit'"
      input = $stdin.gets.strip
      case input
        when 'h'
          player.hand.each_with_index {|card, index| puts "#{index+1}) #{card.name}"}
        when 'd'
          player.deck.each_with_index {|card, index| puts "#{index+1}) #{card.name}"}
        when 'n'
          break
        when 'exit'
          exit
        else
          puts 'invalid option'
      end
      puts ""
    end
  end
end