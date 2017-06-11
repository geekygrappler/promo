require 'rails_helper'

describe Cart, type: :model do
  describe 'initialisation' do
    describe 'input values' do
      it 'should still create without an item_total' do
        cart = Cart.new({
          delivery_total: 17
        })

        expect(cart).to be_truthy
        expect(cart.delivery_total).to eq(BigDecimal.new(17))
        expect(cart.item_total).to be_nil
      end
      it 'should still create without a delivery_total' do
        cart = Cart.new({
          item_total: 13
        })

        expect(cart).to be_truthy
        expect(cart.item_total).to eq(BigDecimal.new(13))
        expect(cart.delivery_total).to be_nil
      end
    end
    describe 'decimals' do
      it 'should accept a string and convert it to big decimal' do
        cart = Cart.new({
          item_total: '17'
        })

        expect(cart.item_total).to eq(17)
      end
      it 'should maintain decimals in a string' do
        cart = Cart.new({
          item_total: '16.99'
        })

        expect(cart.item_total).to eq(16.99)
      end
    end
    describe 'cart total' do
      it 'should calculate the cart total as the sum of item_total and delivery_total' do
        cart = Cart.new({
          'item-total': '13.29',
          'delivery-total': '7.49'
        })

        cart2 = Cart.new({
          item_total: '13.29'
        })

        cart3 = Cart.new({
          delivery_total: '7.49'
        })

        expect(cart.total).to eq(20.78)
        expect(cart2.total).to eq(13.29)
        expect(cart3.total).to eq(7.49)
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

      expect(cart.item_total).to eq(3)
      expect(cart.total).to eq(10)
    end

    it 'should update the delivery total and recalculate the total' do
      cart = Cart.new({
        'item-total': '13',
        'delivery-total': '7'
      })

      cart.update_attr('delivery_total', 3)

      expect(cart.delivery_total).to eq(3)
      expect(cart.total).to eq(16)
    end
  end
end