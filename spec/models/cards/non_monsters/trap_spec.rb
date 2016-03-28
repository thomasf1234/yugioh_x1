require 'spec_helper'
require 'shoulda/matchers'

RSpec.describe Trap, type: :model do
  describe 'associations' do
    [:card].each do |association|
      it { is_expected.to belong_to association }
    end
  end

  describe 'attributes' do
    [:id, :name, :number, :description, :effect_types, :property, :image_path, :card_id].each do |attribute|
      it { is_expected.to respond_to(attribute) }
    end
  end
end
