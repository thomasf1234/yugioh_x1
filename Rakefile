# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../yugioh_x1', __FILE__)
Dir.glob('lib/tasks/*.rake').each { |file| load(file) }

desc "console session"
task :console do
  require 'pry'; binding.pry
end

desc "run command"
task :run, [:command]  do |t, args|
  eval(args[:command])
  puts 'exiting'
end


desc "test game"
task :test_game do
  deck1 = Deck.new([DarkMagician.new, CelticGuardian.new, GiantSoldierOfStone.new])
  deck2 = Deck.new([CelticGuardian.new, CelticGuardian.new, CelticGuardian.new, GiantSoldierOfStone.new])
  player1 = Player.new('Yugi', deck1)
  player2 = Player.new('Seto', deck2)
  game = Duel.new([player1, player2])
  game.start
end

desc "sync_cards"
task :sync_cards, [:gallery_list_url]  do |t, args|
  page = Nokogiri::HTML(open(args[:gallery_list_url]))
  names = page.xpath("//a[contains(@href,'/wiki/Card_Gallery:')]").map {|anchor| anchor.attribute('href').value[19..-1] }


  names.each do |name|
    SyncCardData.perform(name)
    sleep(2)
  end
end