require 'spec_helper'

describe Player do
  let(:player) { Player.new('Yugi', deck) }
  let(:deck) { Deck.new(cards) }
  let(:cards) do
    [
        :dark_magician,
        :celtic_guardian,
        :giant_soldier_of_stone
    ]
  end

  describe '#initialize' do
    it 'assigns the deck' do
      expect(player.deck).to eq(deck)
      expect(player.hand).to be_empty
    end
  end

  describe '#draw' do
    before :each do
      player.draw
    end

    it 'draws a single card from the top of the deck' do
      expect(player.deck).to eq([:celtic_guardian, :giant_soldier_of_stone])
      expect(player.hand).to eq([:dark_magician])
    end
  end

  describe '#shuffle!' do
    before :each do
      player.shuffle!(:deck)
    end

    it 'draws a single card from the top of the deck' do
      expect(player.deck).to match_array([:celtic_guardian, :dark_magician, :giant_soldier_of_stone])
      expect(player.hand).to be_empty
    end
  end
end