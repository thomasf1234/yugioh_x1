#<Encoding:UTF-8>

require_relative 'lib/yugioh_x1'

begin; Gosu::enable_undocumented_retrofication; rescue; end

#Window, will be responsible for user input output
class Window < Gosu::Window
  attr_accessor :game, :current_scene

  def initialize(game)
    super(640, 480, false)
    self.caption = 'Yu-Gi-Oh! x1'
    @game = game
    @current_scene = TitleScene.new(self)
  end

  def update
    basis = {
        Gosu::KbEscape => 'Esc',
             Gosu::KbH => 'h',
             Gosu::KbD => 'd',
             Gosu::KbN => 'n',
             Gosu::KbE => 'exit'
    }
    hash = { 'keys' => basis.select {|key, val| button_down?(key)}.values }

    if button_down?(Gosu::KbEscape)
      exit
    end

    Communications::Output.new.broadcast(hash)
  end

  def draw
    @current_scene.draw

    Gosu::Font.new(self, Gosu::default_font_name, 32).draw("Scene: #{@current_scene.class.name}", 0, 0, 0)
  end
end

game = Game.new

window = Window.new(game)

game_thread = Thread.new { game.start }

window.show

game_thread.join