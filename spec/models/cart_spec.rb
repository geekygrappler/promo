require 'rails_helper'

#TODO test string -> decimal conversion & 
describe Cart, type: :model do
  describe 'initialisation' do
    describe 'cart total' do
      it 'should return provided cart total even if it is different to the sum' do
        cart = Cart.new({
          'item-total': '13',
          'delivery-total': '7',
          'total': '21'
        })

        expect(cart.total).to eq(21)
      end
      it 'should calculate a cart total from item total and delivery total' do
        cart = Cart.new({
         'item-total': '13',
         'delivery-total': '7'
        })

        expect(cart.total).to eq(20)
      end
      it 'should handle decimals correctly in the total' do
        cart = Cart.new({
          'total': '13.99'
        })

        expect(cart.total).to eq(13.99)
      end
    end
  end
end