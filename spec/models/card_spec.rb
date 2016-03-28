require 'spec_helper'
require 'shoulda/matchers'

RSpec.describe Card, type: :model do
  describe 'associations' do
    [:artworks].each do |association|
      it { is_expected.to have_many association }
    end
  end

  describe 'attributes' do
    [:id, :name, :number, :description, :effect_types].each do |attribute|
      it { is_expected.to respond_to(attribute) }
    end
  end

  describe 'validations' do
    [:name, :description].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end
  end
end
