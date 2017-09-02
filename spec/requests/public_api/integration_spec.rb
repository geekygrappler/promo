require 'rails_helper'

describe 'Specific Customer Constraints' do
  let(:promotion_name) { 'Specific Customer Promotion' }
  let(:start_date) { DateTime.now.utc.iso8601 }
  let(:end_date) { (DateTime.now + 60).utc.iso8601 }
  let(:user)  {User.create(email: 'test@test.com') }
  let(:api_key) { ApiKey.create(user: user) }
  let(:customer_email) { 'bob@hotmail.com' }
  let(:authorization_header) {
    {
      Authorization: api_key.access_token
    }
  }
  before(:each) do
    @promotion = create(:promotion)
    @promotion.add_constraint 'SpecificCustomerConstraint'
    @promotion.add_modifier('ItemsPercentageModifier', { items_percentage_discount: 50 })
  end
  it 'Can generate a promocode, price a basket, and redeem that basket' do
    generate_params = {
      data: {
        type: 'promocodes',
        attributes: {
          customer_email: customer_email
        },
        relationships: {
          promotion: {
            type: 'promotions',
            id: @promotion.id
          }
        }
      }
    }

    post '/api/v1/promocodes/generate', params: generate_params, headers: authorization_header

    expect(Promocode.all.count).to eq(1)

    code = json_api_attributes['code']

    price_params = {
      data: {
        type: 'promocodes',
        attributes: {
          code: code,
          customer_email: customer_email
        },
        relationships: {
          cart: {
            type: 'carts',
            id: 'userGeneratedCartId',
            attributes: {
              item_total: 27,
              delivery_total: 7
            }
          }
        }
      }
    }

    post '/api/v1/promocodes/price', params: price_params, headers: authorization_header

    expect(Discount.all.count).to eq(1)

    expect(Discount.first.original_cart.item_total).to eq(27)

    redemption_params = {
      data: {
        type: 'carts',
        id: 'userGeneratedCartId'
      }
    }

    post '/api/v1/carts/redeem', params: redemption_params, headers: authorization_header

    expect(Redemption.all.count).to eq(1)

    expect(Redemption.first.discounts.first).to eq(Discount.first)

    expect(Redemption.first.discounts.first.promocode).to eq(Promocode.first)
  end
end