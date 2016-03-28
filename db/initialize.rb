require_relative 'card_data_fetcher'

db_name = "db_#{ENV['ENV']}"

ActiveRecord::Base.logger = Logger.new(File.open("log/#{db_name}.log", 'w+'))

ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => db_name
)

def drop_tables
  connection = ActiveRecord::Base.connection
  connection.execute("SELECT name FROM sqlite_master WHERE type = 'table' and name != 'sqlite_sequence'").each do |result|
    table_name = result['name']
    connection.execute("DROP TABLE '#{table_name}'")
  end
end

drop_tables if ENV['ENV'] == 'test'


ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include?('cards')
    create_table :cards do |table|
      table.column :name,     :string
      table.column :number, :integer
      table.column :description, :string
      table.column :effect_types, :text
    end
  end

  unless ActiveRecord::Base.connection.tables.include?('artworks')
    create_table :artworks do |table|
      table.column :image_path, :string
      table.column :card_id, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include?('monsters')
    create_table :monsters do |table|
      table.column :elemental_attribute, :string
      table.column :materials, :string
      table.column :level, :integer
      table.column :rank, :integer
      table.column :types, :text
      table.column :attack, :string
      table.column :defense, :string
      table.column :card_id, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include?('non_monsters')
    create_table :non_monsters do |table|
      table.column :type,     :string
      table.column :property, :string
      table.column :card_id, :integer
    end
  end
end