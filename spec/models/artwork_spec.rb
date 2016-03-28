require 'spec_helper'
require 'shoulda/matchers'

RSpec.describe Artwork, type: :model do
  describe 'associations' do
    [:card].each do |association|
      it { is_expected.to belong_to association }
    end
  end

  describe 'attributes' do
    [:id, :image_path, :card_id].each do |attribute|
      it { is_expected.to respond_to(attribute) }
    end
  end

  describe 'validations' do
    [:image_path].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end
  end
end
