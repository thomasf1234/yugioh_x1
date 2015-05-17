require_relative '../phase'

class DrawPhase < Phase
  def on_start
    puts "draw a card: (y/n)"
    input = $stdin.gets.strip
    player.draw if input.downcase == 'y'
  end
end