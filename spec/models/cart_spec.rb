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

  describe 'updates' do
    it 'should update the item total and recalculate the total' do
      cart = Cart.new({
        'item-total': '13',
        'delivery-total': '7'
      })

      cart.update_attr('item_total', 3)

      expect(cart.item_total).to eq(Monetize.parse(3))
      expect(cart.total).to eq(Monetize.parse(10))
    end

    it 'should update the delivery total and recalculate the total' do
      cart = Cart.new({
        'item-total': '13',
        'delivery-total': '7'
      })

      cart.update_attr('delivery_total', 3)

      expect(cart.delivery_total).to eq(Monetize.parse(3))
      expect(cart.total).to eq(Monetize.parse(16))
    end
  end
end