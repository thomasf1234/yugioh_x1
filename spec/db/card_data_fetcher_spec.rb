require 'spec_helper'

describe CardDataFetcher do
  before :each do
    stub_request(:any, /#{CardDataFetcher::YUGIOH_WIKIA_URL}.*/).to_return do |request|
      card_name = request.uri.to_s.split('/').last
      temp_file = Tempfile.new('card_data_fetcher_test')
      temp_file.write(File.read("spec/samples/db/card_data_fetcher/stubs/#{card_name}"))
      temp_file.close
      { body: temp_file.open, status: 200 }
    end
  end

  describe '#fetch' do
    context 'Normal Monster' do
      before :each do
        CardDataFetcher.new.fetch('Dark_Magician')
      end

      it 'writes the specific card data into the correct tables' do
        expect(Card.count).to eq(1)
        expect(Monster.count).to eq(1)

        monster = Monster.first
        expect(monster.name).to eq('Dark Magician')
        expect(monster.number).to eq(46986414)
        expect(monster.description).to eq('The ultimate wizard in terms of attack and defense.')
        expect(monster.effect_types).to eq([])
        expect(monster.elemental_attribute).to eq('DARK')
        expect(monster.materials).to eq(nil)
        expect(monster.level).to eq(7)
        expect(monster.rank).to eq(nil)
        expect(monster.types).to eq(['Spellcaster'])
        expect(monster.attack).to eq('2500')
        expect(monster.defense).to eq('2100')

        # expect(JSON.parse(monster.card.to_json).except('id')).to eq({
        #                                      'name' => 'Dark Magician',
        #                                      'number' => '46986414',
        #                                      'description' => 'The ultimate wizard in terms of attack and defense.',
        #                                      'effect_types' => [],
        #                                      'image_path' => 'db/images/pictures/DarkMagician-OW.png',
        #                                  })
      end
    end
  end
end

