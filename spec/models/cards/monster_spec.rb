require 'spec_helper'
require 'shoulda/matchers'

RSpec.describe Monster, type: :model do
  describe 'associations' do
    [:card].each do |association|
      it { is_expected.to belong_to association }
    end
  end

  describe 'attributes' do
    [:id, :name, :number, :description, :effect_types, :image_path, :card_id,
     :elemental_attribute, :materials, :level, :rank, :types, :attack, :defense].each do |attribute|
      it { is_expected.to respond_to(attribute) }
    end
  end
end
