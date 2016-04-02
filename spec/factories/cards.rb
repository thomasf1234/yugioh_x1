FactoryGirl.define do
  factory :card, class: Card do
    name 'Dark Magician'
    serial_number '46986414'
    description 'The ultimate wizard in terms of attack and defense.'
    category 'Normal'

    after(:create) do |card|
      card.properties << [
          Property.new({name: 'element', value: 'DARK', data_type: 'string'}),
          Property.new({name: 'level', value: '7', data_type: 'integer'}),
          Property.new({name: 'attack', value: '2500', data_type: 'integer'}),
          Property.new({name: 'defense', value: '2100', data_type: 'integer'}),
          Property.new({name: 'species', value: 'Normal', data_type: 'string'})
      ]
    end
  end
end
