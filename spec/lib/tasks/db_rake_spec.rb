require 'spec_helper'
require 'digest/md5'

describe 'db.rake' do
  let(:dummy_env) { 'dummy_env' }
  let(:dummy_db_name) { "db_#{dummy_env}" }

  after :each do
    FileUtils.rm(dummy_db_name) if File.exists?(dummy_db_name)
  end

  describe 'db:drop' do
    context 'database exists' do
      before :each do
        within_environment(dummy_env) { execute_rake('db:create') }
      end

      it 'drops the database' do
        within_environment(dummy_env) do
          expect(File.exists?(dummy_db_name)).to eq(true)
          execute_rake('db:drop')
          expect(File.exists?(dummy_db_name)).to eq(false)
        end
      end
    end

    context 'database does not exist' do
      it 'does nothing' do
        within_environment(dummy_env) do
          execute_rake('db:drop')
          expect(File.exists?(dummy_db_name)).to eq(false)
        end
      end
    end
  end

  describe 'db:backup' do
    before :each do
      FileUtils.rm_rf('db/backups/test') if File.directory?('db/backups/test')
    end

    it 'creates a gzip archive file of a dump' do
      expect(File.exists?('db/backups/test/db_test_20160402000438.bak.gz')).to eq(false)

      Timecop.freeze(DateTime.parse('2016-04-02T00:04:38+00:00')) do
        FactoryGirl.create(:card)
        expect(Card.find_by_name('Dark Magician')).not_to eq(nil)
        execute_rake('db:backup')
      end

      expect(File.exists?('db/backups/test/db_test_20160402000438.bak.gz')).to eq(true)
      expect(Digest::MD5.file('db/backups/test/db_test_20160402000438.bak.gz').to_s).to eq('ef58fe8dc7b627c9b91e1fedc25a9a47')
    end
  end

  describe 'db:restore' do
    let(:source) { File.join('spec/samples/lib/tasks', backup_name) }
    let(:temp_file) { File.join('tmp', backup_name) }
    let(:unzipped_temp_file) { File.join('tmp', 'db_dummy_env_20160402203442.bak') }
    let(:backup_name) { 'db_dummy_env_20160402203442.bak.gz' }

    context 'database already exists' do
      before :each do
        within_environment(dummy_env) do
          execute_rake("db:reset")
        end
      end

      it 'does not restore' do
        within_environment(dummy_env) do
          execute_rake("db:restore", {source: source})
          expect(File.exists?(source)).to eq(true)
          [temp_file, unzipped_temp_file].each do |file|
            expect(File.exists?(file)).to eq(false)
          end

          expect(Card.count).to eq(0)
        end
      end
    end

    context 'database does not exist' do
      let(:properties_as_json) do
        [{"id"=>1, "name"=>"element", "value"=>"DARK", "card_id"=>1},
         {"id"=>2, "name"=>"level", "value"=>"7", "card_id"=>1},
         {"id"=>3, "name"=>"attack", "value"=>"2500", "card_id"=>1},
         {"id"=>4, "name"=>"defense", "value"=>"2100", "card_id"=>1},
         {"id"=>5, "name"=>"species", "value"=>"Spellcaster", "card_id"=>1}]
      end
      let(:cards_as_json) do
        [{"id"=>1, "name"=>"Dark Magician", "serial_number"=>"46986414", "description"=>"The ultimate wizard in terms of attack and defense.", "category"=>"Normal"}]
      end
      let(:artworks_as_json) do
        [{"id"=>1, "image_path"=>"tmp/pictures/DarkMagician-OW.png", "card_id"=>1},
         {"id"=>2, "image_path"=>"tmp/pictures/DarkMagician-OW-2.png", "card_id"=>1},
         {"id"=>3, "image_path"=>"tmp/pictures/DarkMagician-TF05-JP-VG.png", "card_id"=>1},
         {"id"=>4, "image_path"=>"tmp/pictures/DarkMagician-TF05-JP-VG-2.png", "card_id"=>1},
         {"id"=>5, "image_path"=>"tmp/pictures/DarkMagician-TF05-JP-VG-3.png", "card_id"=>1},
         {"id"=>6, "image_path"=>"tmp/pictures/DarkMagician-TF05-JP-VG-4.png", "card_id"=>1},
         {"id"=>7, "image_path"=>"tmp/pictures/DarkMagician-TF05-JP-VG-5.png", "card_id"=>1}]
      end

      before :each do
        within_environment(dummy_env) do
          execute_rake("db:drop")
        end
      end

      it 'copies and unzips the archive file, restores the data, and then removes the copy' do
        within_environment(dummy_env) do
          execute_rake("db:restore", {source: source})
          expect(File.exists?(source)).to eq(true)
          [temp_file, unzipped_temp_file].each do |file|
            expect(File.exists?(file)).to eq(false)
          end

          expect(Card.all.as_json).to match_array(cards_as_json)
          expect(Property.all.as_json).to match_array(properties_as_json)
          expect(Artwork.all.as_json).to match_array(artworks_as_json)
          expect_all_other_tables_to_be_empty([Card, Monster, Property, Artwork])
        end
      end
    end
  end
end
