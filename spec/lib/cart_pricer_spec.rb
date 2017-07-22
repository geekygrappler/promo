require 'rails_helper'

describe 'Cart Pricer' do

  describe 'price' do
    xit 'should initialize a ItemsPercentageModifier and call apply on it passing a cart' do
      cart_pricer = CartPricer.new
      mock_cart = instance_double('Cart')
      mock_promocode = instance_double('Promocode')
      mock_promotion = instance_double('Promotion')
      mock_items_percentage_modifier = instance_double('ItemsPercentageModifier')

      expect(mock_promocode).to receive(:promotion).and_return(mock_promotion)
      expect(mock_promotion).to receive(:modifiers).and_return(['ItemsPercentageModifier'])
      # TODO :const_get is on Module but this test complains
      expect_any_instance_of(Modifiers).to receive(:const_get).with('ItemsPercentageModifier').and_return(mock_items_percentage_modifier)
      expect(mock_items_percentage_modifier).to receive(:new).with(mock_promocode, mock_promotion)
      expect(mock_items_percentage_modifier).to receive(:apply).with(mock_cart).and_return(nil)
      cart_pricer.price(mock_cart, mock_promocode)
    end
  end
end