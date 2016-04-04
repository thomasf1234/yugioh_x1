require 'spec_helper'

describe SyncCardData do
  before :each do
    FileUtils.mkdir_p(ENVIRONMENT_CONFIG['image_folder'])

    stub_request(:any, /.*/).to_return do |request|
      file_name = request.uri.to_s.split('/').last
      temp_file = Tempfile.new('sync_card_data_test')
      temp_file.write(File.read("spec/samples/db/sync_card_data/stubs/#{file_name}"))
      temp_file.close
      { body: temp_file.open, status: 200 }
    end
  end

  describe 'card_type' do
    context 'Normal Monster' do
      it 'should be Normal' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new('Dark_Magician'))).to eq(Card::Categories::NORMAL)
      end
    end

    context 'Normal Tuner Monster' do
      it 'should be Normal' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new('Ally_Mind'))).to eq(Card::Categories::NORMAL)
      end
    end

    context 'Effect Monster' do
      it 'should be Effect' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new("Van'Dalgyon_the_Dark_Dragon_Lord"))).to eq(Card::Categories::EFFECT)
      end
    end

    context 'Fusion Monster' do
      it 'should be Fusion' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new("Black_Skull_Dragon"))).to eq(Card::Categories::FUSION)
      end
    end

    context 'Ritual Monster' do
      it 'should be Ritual' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new("Relinquished"))).to eq(Card::Categories::RITUAL)
      end
    end

    context 'Synchro Monster' do
      it 'should be Synchro' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new('Stardust_Dragon'))).to eq(Card::Categories::SYNCHRO)
      end
    end

    context 'Synchro Tuner Monster' do
      it 'should be Synchro' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new('Formula_Synchron'))).to eq(Card::Categories::SYNCHRO)
      end
    end

    context 'Xyz Monster' do
      it 'should be Xyz' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new('Bahamut_Shark'))).to eq(Card::Categories::XYZ)
      end
    end

    context 'Spell Card' do
      it 'should be Normal' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new('Monster_Reborn'))).to eq(Card::Categories::SPELL)
      end
    end

    context 'Trap Card' do
      it 'should be Normal' do
        expect(SyncCardData.send(:card_type, ExternalPages::MainPage.new('Trap_Hole'))).to eq(Card::Categories::TRAP)
      end
    end
  end

  describe '#perform' do
    context 'Normal Monster' do
      before :each do
        SyncCardData.perform('Dark_Magician')
      end

      it 'writes the specific card data into the correct tables' do
        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(7)
        expect(CardEffect.count).to eq(0)

        card = Monster.first

        expect(card.name).to eq('Dark Magician')
        expect(card.category).to eq(Card::Categories::NORMAL)
        expect(card.element).to eq(Monster::Elements::DARK)
        expect(card.level).to eq('7')
        expect(card.rank).to eq(nil)
        expect(card.species).to eq(Monster::Species::SPELLCASTER)
        expect(card.abilities).to eq([])
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
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Normal Tuner Monster' do
      before :each do
        SyncCardData.perform('Ally_Mind')
      end

      it 'writes the specific card data into the correct tables' do
        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(1)
        expect(CardEffect.count).to eq(0)

        card = Monster.first

        expect(card.name).to eq('Ally Mind')
        expect(card.category).to eq(Card::Categories::NORMAL)
        expect(card.element).to eq(Monster::Elements::DARK)
        expect(card.level).to eq('5')
        expect(card.rank).to eq(nil)
        expect(card.species).to eq(Monster::Species::MACHINE)
        expect(card.abilities.map(&:value)).to eq([Monster::Abilities::TUNER])
        expect(card.card_effects).to eq([])
        expect(card.description).to eq("A high-performance unit developed to enhance the Artificial Intelligence program of the Allies of Justice. Loaded with elements collected from a meteor found in the Worm Nebula, it allows for highly tuned performance. But its full capacity is not yet determined.")
        expect(card.attack).to eq('1800')
        expect(card.defense).to eq('1400')
        expect(card.serial_number).to eq('40155554')
        expect(card.artworks.map(&:image_path)).to match_array(["tmp/pictures/AllyMind-TF04-JP-VG.png"])

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Effect Monster' do
      before :each do
        SyncCardData.perform("Van'Dalgyon_the_Dark_Dragon_Lord")
      end

      it 'writes the specific card data into the correct tables' do
        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(1)
        expect(CardEffect.count).to eq(0)

        card = Monster.first

        expect(card.name).to eq("Van'Dalgyon the Dark Dragon Lord")
        expect(card.category).to eq(Card::Categories::EFFECT)
        expect(card.element).to eq(Monster::Elements::DARK)
        expect(card.level).to eq('8')
        expect(card.rank).to eq(nil)
        expect(card.species).to eq(Monster::Species::DRAGON)
        expect(card.abilities).to eq([])
        expect(card.card_effects).to eq([])
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
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Ritual Monster' do
      before :each do
        SyncCardData.perform("Relinquished")
      end

      it 'writes the specific card data into the correct tables' do
        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(2)
        expect(CardEffect.count).to eq(0)

        card = Monster.first

        expect(card.name).to eq("Relinquished")
        expect(card.category).to eq(Card::Categories::RITUAL)
        expect(card.element).to eq(Monster::Elements::DARK)
        expect(card.level).to eq('1')
        expect(card.rank).to eq(nil)
        expect(card.species).to eq(Monster::Species::SPELLCASTER)
        expect(card.abilities).to eq([])
        expect(card.card_effects).to eq([])
        expect(card.description).to eq("You can Ritual Summon this card with \"Black Illusion Ritual\". Once per turn: You can target 1 monster your opponent controls; equip that target to this card. (You can only equip 1 monster at a time to this card with this effect.) This card's ATK and DEF become equal to that equipped monster's. If this card would be destroyed by battle, destroy that equipped monster instead. While equipped with that monster, any battle damage you take from battles involving this card inflicts equal effect damage to your opponent.")
        expect(card.attack).to eq('0')
        expect(card.defense).to eq('0')
        expect(card.serial_number).to eq('64631466')
        expect(card.artworks.map(&:image_path)).to match_array(["tmp/pictures/Relinquished-TF04-JP-VG.jpg", "tmp/pictures/Relinquished-OW.png"])

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Fusion Monster' do
      before :each do
        SyncCardData.perform("Thousand-Eyes_Restrict")
      end

      it 'writes the specific card data into the correct tables' do
        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(2)
        expect(CardEffect.count).to eq(0)

        card = Monster.first

        expect(card.name).to eq("Thousand-Eyes Restrict")
        expect(card.category).to eq(Card::Categories::FUSION)
        expect(card.element).to eq(Monster::Elements::DARK)
        expect(card.level).to eq('1')
        expect(card.rank).to eq(nil)
        expect(card.species).to eq(Monster::Species::SPELLCASTER)
        expect(card.abilities).to eq([])
        expect(card.card_effects).to eq([])
        expect(card.description).to eq("\"Relinquished\" + \"Thousand-Eyes Idol\"
Other monsters cannot change their battle position or attack. Once per turn, you can equip 1 monster your opponent controls to this card (max 1). This card's ATK and DEF become the same as the equipped monster's. If this card would be destroyed by battle, the equipped monster is destroyed instead.")
        expect(card.attack).to eq('0')
        expect(card.defense).to eq('0')
        expect(card.serial_number).to eq('63519819')
        expect(card.artworks.map(&:image_path)).to match_array(["tmp/pictures/ThousandEyesRestrict-TF04-JP-VG.jpg", "tmp/pictures/ThousandEyesRestrict-OW.png"])

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Synchro Monster' do
      before :each do
        SyncCardData.perform("Red_Dragon_Archfiend")
      end

      it 'writes the specific card data into the correct tables' do
        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(2)
        expect(CardEffect.count).to eq(0)

        card = Monster.first

        expect(card.name).to eq("Red Dragon Archfiend")
        expect(card.category).to eq(Card::Categories::SYNCHRO)
        expect(card.element).to eq(Monster::Elements::DARK)
        expect(card.level).to eq('8')
        expect(card.rank).to eq(nil)
        expect(card.species).to eq(Monster::Species::DRAGON)
        expect(card.abilities).to eq([])
        expect(card.card_effects).to eq([])
        expect(card.description).to eq("1 Tuner + 1 or more non-Tuner monsters
After damage calculation, if this card attacks a Defense Position monster your opponent controls: Destroy all Defense Position monsters your opponent controls. During your End Phase: Destroy all other monsters you control that did not declare an attack this turn. This card must be face-up on the field to activate and to resolve this effect.")
        expect(card.attack).to eq('3000')
        expect(card.defense).to eq('2000')
        expect(card.serial_number).to eq('70902743')
        expect(card.artworks.map(&:image_path)).to match_array(["tmp/pictures/RedDragonArchfiend-TF04-JP-VG.jpg", "tmp/pictures/RedDragonArchfiend-OW.png"])

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Synchro Tuner Monster, TFS artwork' do
      before :each do
        SyncCardData.perform("Accel_Synchron")
      end

      it 'writes the specific card data into the correct tables' do
        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(1)
        expect(CardEffect.count).to eq(0)

        card = Monster.first

        expect(card.name).to eq("Accel Synchron")
        expect(card.category).to eq(Card::Categories::SYNCHRO)
        expect(card.element).to eq(Monster::Elements::DARK)
        expect(card.level).to eq('5')
        expect(card.rank).to eq(nil)
        expect(card.species).to eq(Monster::Species::MACHINE)
        expect(card.abilities.map(&:value)).to eq([Monster::Abilities::TUNER])
        expect(card.card_effects).to eq([])
        expect(card.description).to eq("1 Tuner + 1 or more non-Tuner monsters
Once per turn: You can send 1 \"Synchron\" monster from your Deck to the Graveyard, then activate 1 of these effects;
● Increase this card's Level by the Level of the sent monster.
● Reduce this card's Level by the Level of the sent monster.
During your opponent's Main Phase, you can: Immediately after this effect resolves, Synchro Summon 1 Synchro Monster, using Materials including this card you control (this is a Quick Effect). You can only Synchro Summon \"Accel Synchron(s)\" once per turn.")
        expect(card.attack).to eq('500')
        expect(card.defense).to eq('2100')
        expect(card.serial_number).to eq('37675907')
        expect(card.artworks.map(&:image_path)).to match_array(["tmp/pictures/AccelSynchron-TFS-JP-VG.png"])

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Xyz Monster, no artworks available' do
      before :each do
        SyncCardData.perform("Bahamut_Shark")
      end

      it 'writes the specific card data into the correct tables' do
        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(0)
        expect(CardEffect.count).to eq(0)

        card = Monster.first

        expect(card.name).to eq("Bahamut Shark")
        expect(card.category).to eq(Card::Categories::XYZ)
        expect(card.element).to eq(Monster::Elements::WATER)
        expect(card.level).to eq(nil)
        expect(card.rank).to eq('4')
        expect(card.species).to eq(Monster::Species::SEA_SERPENT)
        expect(card.abilities).to eq([])
        expect(card.card_effects).to eq([])
        expect(card.description).to eq("2 Level 4 WATER monsters
Once per turn: You can detach 1 Xyz Material from this card; Special Summon 1 Rank 3 or lower WATER Xyz Monster from your Extra Deck. This card cannot attack for the rest of this turn.")
        expect(card.attack).to eq('2600')
        expect(card.defense).to eq('2100')
        expect(card.serial_number).to eq('00440556')
        expect(card.artworks.map(&:image_path)).to match_array([])

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Spell Card' do
      before :each do
        SyncCardData.perform('Monster_Reborn')
      end

      it 'creates the correct records' do
        expect(NonMonster.count).to eq(1)
        expect(Artwork.count).to eq(2)
        expect(CardEffect.count).to eq(0)

        card = NonMonster.first

        expect(card.name).to eq('Monster Reborn')
        expect(card.category).to eq(Card::Categories::SPELL)
        expect(card.property).to eq(NonMonster::Properties::NORMAL)
        expect(card.card_effects).to eq([])
        expect(card.description).to eq("Target 1 monster in either player's Graveyard; Special Summon it.")
        expect(card.serial_number).to eq('83764718')
        expect(card.artworks.map(&:image_path)).to match_array(["tmp/pictures/MonsterReborn-TF04-JP-VG.png", "tmp/pictures/MonsterReborn-OW.png"])
        [:element, :level, :rank, :species, :abilities, :attack, :defense].each do |attribute|
          expect(card.respond_to?(attribute)).to eq(false)
        end


        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'Trap Card' do
      before :each do
        SyncCardData.perform('Mirror_Wall')
      end

      it 'creates the correct record' do
        expect(NonMonster.count).to eq(1)
        expect(Artwork.count).to eq(2)
        expect(CardEffect.count).to eq(0)

        card = NonMonster.first

        expect(card.name).to eq('Mirror Wall')
        expect(card.category).to eq(Card::Categories::TRAP)
        expect(card.property).to eq(NonMonster::Properties::CONTINUOUS)
        expect(card.card_effects).to eq([])
        expect(card.description).to eq("Each of your opponent's monsters that conducted an attack while this card was face-up on the field has its ATK halved as long as this card remains on the field. During each of your Standby Phases, pay 2000 LP or destroy this card.")
        expect(card.serial_number).to eq('22359980')
        expect(card.artworks.map(&:image_path)).to match_array(["tmp/pictures/MirrorWall-TF04-JP-VG.jpg", "tmp/pictures/MirrorWall-OW.png"])

        [:element, :level, :rank, :species, :abilities, :attack, :defense].each do |attribute|
          expect(card.respond_to?(attribute)).to eq(false)
        end

        #correct files downloaded
        card.artworks.each do |artwork|
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'card already exists' do
      let!(:old_card) { FactoryGirl.create(:card, serial_number: 'wrong_number') }

      before :each do
        SyncCardData.perform('Dark_Magician')
      end

      it 'destroys and recreates the card info' do
        expect(Card.where(id: old_card.id)).to eq([])
        expect(Property.where(card_id: old_card.id)).to eq([])
        expect(Artwork.where(card_id: old_card.id)).to eq([])
        expect(CardEffect.where(card_id: old_card.id)).to eq([])

        expect(Monster.count).to eq(1)
        expect(Artwork.count).to eq(7)
        expect(CardEffect.count).to eq(0)

        card = Monster.first

        expect(card.name).to eq('Dark Magician')
        expect(card.category).to eq(Card::Categories::NORMAL)
        expect(card.element).to eq(Monster::Elements::DARK)
        expect(card.level).to eq('7')
        expect(card.species).to eq(Monster::Species::SPELLCASTER)
        expect(card.abilities).to eq([])
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
          sample_path = File.join('spec/samples/db/sync_card_data/stubs/', File.basename(artwork.image_path))
          expect(File.read(artwork.image_path)).to eq(File.read(sample_path))
        end
      end
    end

    context 'error' do
      before :each do
        allow_any_instance_of(Card).to receive(:artworks).and_raise(RuntimeError.new('Something went wrong'))
      end

      it 'does not create the card' do
        expect { SyncCardData.perform('Dark_Magician') }.to_not raise_error

        expect(Card.count).to eq(0)
        expect(Property.count).to eq(0)
        expect(Artwork.count).to eq(0)
        expect(CardEffect.count).to eq(0)
      end
    end
  end
end

