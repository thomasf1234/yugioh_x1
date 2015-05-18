require 'spec_helper'

describe TextureGenerator do
  let(:texture_generator) { TextureGenerator.new(card) }
  let(:card) do
    double(Card, image_path: 'spec/samples/texture_generator/card_pic.png', attribute: 'TRAP')
  end
  let(:sample_file) { 'spec/samples/texture_generator/sample_generate.bmp' }

  describe '#generate' do
    before :each do
      texture_generator.generate.write('tmp/test.bmp')
    end

    it 'constructs the card texture' do
      expect(FileUtils.compare_file('tmp/test.bmp', sample_file)).to eq(true)
    end
  end
end