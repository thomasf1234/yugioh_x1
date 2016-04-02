require_relative 'card_data_fetcher'

db_name = "db_#{ENV['ENV']}"

ActiveRecord::Base.logger = Logger.new(File.open("log/#{db_name}.log", 'w+'))

ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => db_name
)




























# #Card
# :name
# :serial_number
# :description
# :type
#
# #Artworks
# :image_path
# :card_id
#
# # #Normal
# # :level, :string
# # :elemental_attribute, :string
# # :monster_type, :string  #Spellcaster
# # :attack, :string
# # :defense, :string
#
# #Properties
# :property #ability, summon_condition, spell_trap_property, level, attribute, monster_type, attack, defense
# :value
# :data_type
# :card_id
#
# #Effect
# :type #(trigger, continuous, ignition)
# :script_path
# :card_id
#
# #Action
# :type #(activation, summon)
# :spell_speed #(1,2,3 only counter trap)
# :effect_id

