require 'rails_helper'

describe Cart, type: :model do
  describe 'initialisation' do
    describe 'cart total' do
      it 'should return provided cart total even if it is different to the sum' do
        cart = Cart.new({
          'item-total': '13',
          'delivery-total': '7',
          'total': '21'
        })

        expect(cart.total).to eq(Monetize.parse(21))
      end
      it 'should calculate a cart total from item total and delivery total' do
        cart = Cart.new({
         'item-total': '13',
         'delivery-total': '7'
        })

        expect(cart.total).to eq(Monetize.parse(20))
      end
    end
  end
end