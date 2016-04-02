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

  describe 'card_type' do
    context 'Normal Monster' do
      it 'should be Normal' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new('Dark_Magician'))).to eq(Card::Types::NORMAL)
      end
    end

    context 'Normal Tuner Monster' do
      it 'should be Normal' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new('Ally_Mind'))).to eq(Card::Types::NORMAL)
      end
    end

    context 'Effect Monster' do
      it 'should be Effect' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new("Van'Dalgyon_the_Dark_Dragon_Lord"))).to eq(Card::Types::EFFECT)
      end
    end

    context 'Fusion Monster' do
      it 'should be Fusion' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new("Black_Skull_Dragon"))).to eq(Card::Types::FUSION)
      end
    end

    context 'Ritual Monster' do
      it 'should be Ritual' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new("Relinquished"))).to eq(Card::Types::RITUAL)
      end
    end

    context 'Synchro Monster' do
      it 'should be Synchro' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new('Stardust_Dragon'))).to eq(Card::Types::SYNCHRO)
      end
    end

    context 'Synchro Tuner Monster' do
      it 'should be Synchro' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new('Formula_Synchron'))).to eq(Card::Types::SYNCHRO)
      end
    end

    context 'Xyz Monster' do
      it 'should be Xyz' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new('Bahamut_Shark'))).to eq(Card::Types::XYZ)
      end
    end

    context 'Spell Card' do
      it 'should be Normal' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new('Monster_Reborn'))).to eq(Card::Types::SPELL)
      end
    end

    context 'Trap Card' do
      it 'should be Normal' do
        expect(CardDataFetcher.send(:card_type, ExternalPages::MainPage.new('Trap_Hole'))).to eq(Card::Types::TRAP)
      end
    end
  end

  describe '#fetch' do
    context 'Normal Monster' do
      before :each do
        CardDataFetcher.fetch('Dark_Magician')
      end

      it 'writes the specific card data into the correct tables' do
        expect(Normal.count).to eq(1)
        expect(Artwork.count).to eq(7)

        card = Normal.first

        expect(card.name).to eq('Dark Magician')
        expect(card.type).to eq('Normal')
        expect(card.elemental_attribute).to eq('DARK')
        expect(card.level).to eq(7)
        expect(card.monster_type).to eq('Spellcaster')
        expect(card.monster_abilities).to eq([])
        expect(card.card_effects).to eq([])
        expect(card.description).to eq("The ultimate wizard in terms of attack and defense.")
        expect(card.attack).to eq('2500')
        expect(card.defense).to eq('2100')
        expect(card.serial_number).to eq('46986414')
        expect(card.artworks.map(&:image_path)).to match_array(["tmp/pictures/DarkMagician-OW.png",
                                                                   "tmp/pictures/DarkMagician-OW-2.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG-2.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG-3.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG-4.png",
                                                                   "tmp/pictures/DarkMagician-TF05-JP-VG-5.png"])

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/card_data_fetcher/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Effect Monster' do
      before :each do
        CardDataFetcher.fetch("Van'Dalgyon_the_Dark_Dragon_Lord")
      end

      it 'writes the specific card data into the correct tables' do
        expect(Effect.count).to eq(1)
        expect(Artwork.count).to eq(1)

        card = Effect.first

        expect(card.name).to eq("Van'Dalgyon the Dark Dragon Lord")
        expect(card.type).to eq('Effect')
        expect(card.elemental_attribute).to eq('DARK')
        expect(card.level).to eq(8)
        expect(card.monster_type).to eq('Dragon')
        expect(card.monster_abilities).to eq([])
        expect(card.card_effects.map(&:type)).to match_array(['CardEffects::Trigger', 'CardEffects::Trigger'])
        expect(card.description).to eq("If you negate the activation of an opponent's Spell/Trap Card(s), or opponent's monster effect(s), with a Counter Trap Card (except during the Damage Step): You can Special Summon this card from your hand. If Summoned this way, activate these effects and resolve in sequence, depending on the type of card(s) negated by that Counter Trap:
● Spell: Inflict 1500 damage to your opponent.
● Trap: Target 1 card your opponent controls; destroy that target.
● Monster: Target 1 monster in your Graveyard; Special Summon it.")
        expect(card.attack).to eq('2800')
        expect(card.defense).to eq('2500')
        expect(card.serial_number).to eq('24857466')
        expect(card.artworks.map(&:image_path)).to match_array(["tmp/pictures/VanDalgyontheDarkDragonLord-TF04-JP-VG.jpg"])

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/card_data_fetcher/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Spell Card' do
      before :each do
        CardDataFetcher.fetch('Monster_Reborn')
      end

      it 'creates the correct raw_card record' do
        expect(Spell.count).to eq(1)
        expect(Artwork.count).to eq(2)

        card = Card.first

        expect(card.name).to eq('Monster Reborn')
        expect(card.type).to eq('Spell')
        expect(card.spell_trap_type).to eq('Normal')
        expect(card.card_effects.count).to eq(1)
        expect(card.card_effects.first.type).to eq('CardEffects::Effect')
        expect(card.description).to eq("Target 1 monster in either player's Graveyard; Special Summon it.")
        expect(card.serial_number).to eq('83764718')
        [:elemental_attribute, :level, :rank, :monster_type, :monster_abilities, :attack, :defense].each do |attribute|
          expect(card.respond_to?(attribute)).to eq(false)
        end

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/card_data_fetcher/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end
  end
end

