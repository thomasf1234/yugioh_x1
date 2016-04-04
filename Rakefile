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

desc "get_card_names"
task :get_card_names do
  first_page = Nokogiri::HTML(open(SyncCardData::YUGIOH_WIKIA_URL + '/wiki/Category:Card_Gallery'))
  pages = [first_page]
  current_page = first_page
  last_page = nil
  until last_page do
    next_page_end_point = try_block { current_page.xpath("//a[text()='next 200']").first.attribute('href').value }
    puts "fetching #{next_page_end_point}"
    if next_page_end_point
      current_page = Nokogiri::HTML(open(SyncCardData::YUGIOH_WIKIA_URL + next_page_end_point))
      pages << current_page
    else
      last_page = current_page
    end
  end

  card_names = pages.map do |page|
    page.xpath("//a[contains(@href,'/wiki/Card_Gallery:')]").map {|anchor| anchor.attribute('href').value[19..-1] }
  end.flatten.uniq

  File.open('db/card_names.csv', 'w') do |file|
    card_names.each do |card_name|
      file.puts card_name
    end
  end
end

desc "sync_cards"
task :sync_cards, [:card_names_path]  do |t, args|
  File.read('db/card_names.csv').split.each do |name|
    SyncCardData.perform(name)
    sleep(10)
  end
end

