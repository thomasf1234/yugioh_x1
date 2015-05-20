class Duel
  attr_accessor :players, :turn

  class << self
    def all
      ObjectSpace.each_object(self).to_a
    end

    def current
      all.first
    end
  end

  def initialize(players)
    @players = players
  end

  def start
    players.each do |player|
      player.life_points = 8000
      player.shuffle!(:deck)
      1.times { player.draw }
      @turn = 0
    end

    results = catch(:duel_end) do
      players.cycle do |player|
        @turn += 1

        [DrawPhase, StandbyPhase, Main1Phase, EndPhase].each do |phase_klass|
          phase = phase_klass.new(player)
          phase.run_hooks
        end
      end
    end

    puts "DUEL END!!!!!"
    puts results
  end
end