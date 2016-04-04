ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include?('cards')
    create_table :cards do |table|
      table.column :name,     :string
      table.column :serial_number, :string
      table.column :description, :string
      table.column :category, :string

      table.index :serial_number
      table.index :name, unique: true
    end
  end

  unless ActiveRecord::Base.connection.tables.include?('artworks')
    create_table :artworks do |table|
      table.column :image_path, :string
      table.column :card_id, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include?('properties')
    create_table :properties do |table|
      table.column :name, :string, null: false
      table.column :value, :string
      table.column :card_id, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include?('card_effects')
    create_table :card_effects do |table|
      table.column :type, :string
      table.column :script_path, :string
      table.column :card_id, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include?('actions')
    create_table :actions do |table|
      table.column :type, :string
      table.column :spell_speed, :integer
      table.column :effect_id, :integer
    end
  end
end
