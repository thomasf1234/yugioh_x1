require 'spec_helper'

describe CardDataFetcher do
  before :each do
    FileUtils.mkdir_p(ENVIRONMENT_CONFIG['image_folder'])

    stub_request(:any, /.*/).to_return do |request|
      file_name = request.uri.to_s.split('/').last
      temp_file = Tempfile.new('card_data_fetcher_test')
      temp_file.write(File.read("spec/samples/db/card_data_fetcher/stubs/#{file_name}"))
      temp_file.close
      { body: temp_file.open, status: 200 }
    end
  end

  describe '#fetch' do
    context 'Normal Monster' do
      before :each do
        CardDataFetcher.fetch('Dark_Magician')
      end

      it 'writes the specific card data into the correct tables' do
        expect(Card.count).to eq(1)
        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(7)

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
        expect(monster.artworks.map(&:image_path)).to match_array(["tmp/pictures/DarkMagician-OW.png",
                                                                   "tmp/pictures/DarkMagician-OW-2.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG-2.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG-3.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG-4.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG-5.png"])

        #correct files downloaded
        monster.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/card_data_fetcher/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end
  end
end

