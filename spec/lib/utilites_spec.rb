require 'spec_helper'

describe Utilities do
  include Utilities

  describe '#try_block' do
    context 'block passed' do
      it 'returns the return value of the block' do
        expect(try_block { 3 + 5 }).to eq(8)
      end
    end

    context 'block raises error' do
      it 'returns nil' do
        expect(try_block { 3 + 'k' }).to eq(nil)
      end
    end
  end
end