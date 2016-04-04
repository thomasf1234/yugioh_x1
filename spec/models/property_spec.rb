require 'spec_helper'
require 'shoulda/matchers'

RSpec.describe Property, type: :model do
  describe 'associations' do
    [:card].each do |association|
      it { is_expected.to belong_to association }
    end
  end

  describe 'attributes' do
    [:id, :name, :value].each do |attribute|
      it { is_expected.to respond_to(attribute) }
    end
  end

  describe 'validations' do
    [{name: Property::Names::ELEMENT, set: Monster::Elements::ALL},
     {name: Property::Names::SPECIES, set: Monster::Species::ALL},
     {name: Property::Names::ABILITY, set: Monster::Abilities::ALL},
     {name: Property::Names::PROPERTY, set: NonMonster::Properties::ALL}].each do |params|
      context "property name is '#{params[:name]}'" do
        it 'validates that the value is within the expected set' do
          expect(Property.new(name: params[:name])).to validate_inclusion_of(:value).in_array(params[:set])
        end
      end
    end
  end
end
