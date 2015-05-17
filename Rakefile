# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../lib/yugioh_x1', __FILE__)

desc "console session"
task :console do
  require 'pry'; binding.pry
end


desc "test game"
task :test_game do
  deck1 = Deck.new([DarkMagician.new, CelticGuardian.new, GiantSoldierOfStone.new])
  deck2 = Deck.new([CelticGuardian.new, CelticGuardian.new, CelticGuardian.new, GiantSoldierOfStone.new])
  player1 = Player.new('Yugi', deck1)
  player2 = Player.new('Seto', deck2)
  game = Game.new([player1, player2])
  game.start
end
