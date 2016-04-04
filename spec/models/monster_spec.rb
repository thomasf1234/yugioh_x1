require 'spec_helper'
require 'shoulda/matchers'

RSpec.describe Monster, type: :model do
  describe 'associations' do
    [:artworks, :abilities, :card_effects].each do |association|
      it { is_expected.to have_many association }
    end
  end

  describe 'attributes' do
    [:card_id, :name, :serial_number, :description, :abilities,
     :element, :level, :rank, :species, :attack, :defense].each do |attribute|
      it { is_expected.to respond_to(attribute) }
    end
  end
end
