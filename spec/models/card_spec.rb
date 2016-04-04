require 'spec_helper'
require 'shoulda/matchers'

RSpec.describe Card, type: :model do
  describe 'associations' do
    [:artworks, :properties, :card_effects].each do |association|
      it { is_expected.to have_many association }
    end
  end

  describe 'attributes' do
    [:id, :name, :serial_number, :description, :category].each do |attribute|
      it { is_expected.to respond_to(attribute) }
    end
  end

  describe 'validations' do
    [:name, :description].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end
  end
end
