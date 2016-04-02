FactoryGirl.define do
  factory :card, class: Card do
    name 'Dark Magician'
    serial_number '46986414'
    description 'The ultimate wizard in terms of attack and defense.'
    type 'Normal'

    after(:create) do |card|
      card.properties << [
          Property.new({name: 'elemental_attribute', value: 'DARK', data_type: 'string'}),
          Property.new({name: 'level', value: '7', data_type: 'integer'}),
          Property.new({name: 'attack', value: '2500', data_type: 'integer'}),
          Property.new({name: 'defense', value: '2100', data_type: 'integer'}),
          Property.new({name: 'monster_type', value: 'Normal', data_type: 'string'})
      ]
    end
  end
end
