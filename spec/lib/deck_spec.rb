require 'spec_helper'

describe Deck do
  it 'is a subclass of Array' do
    expect(Deck.superclass).to eq(Array)
  end
end