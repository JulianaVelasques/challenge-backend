require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'when validating' do
    it 'validates numericality of quantity' do
      cart = described_class.new(quantity: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:quantity]).to include("must be greater than or equal to 0")
    end
  end
end
