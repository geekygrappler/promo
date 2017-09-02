require 'rails_helper'

describe 'Redeem endpoint', type: :request do
  let(:promotion_name) { 'Redemption Promotion' }
  let(:start_date) { DateTime.now.utc.iso8601 }
  let(:end_date) { (DateTime.now + 60).utc.iso8601 }
  let(:user) {User.create(email: 'test@test.com')}
  let(:api_key) {ApiKey.create(user: user)}
  let(:authorization_header) {
    {
      Authorization: api_key.access_token
    }
  }
  let(:code) {'xyz123'}
  let(:user_cart_id) { 'uniqueId' }

  before(:each) do
    @discount = build(:discount)
    @discount.user_cart_id = 'uniqueId'
    @discount.save
    @promocode = @discount.promxocode
  end

  it 'should create a redemption for a cart that has a discount record' do
    params = {
      data: {
        type: 'carts',
        id: @discount.user_cart_id
      }
    }

    post '/api/v1/carts/redeem', params: params, headers: authorization_header

    expect(response).to have_http_status(200)

    expect(Redemption.all.count).to eql(1)
    redemption = Redemption.first
    expect(redemption.promocodes.first).to eql(@promocode)
  end

  it 'should create a redemption for a cart that has two discount records' do
    # Create a second discount record
    @second_discount = build(:discount)
    @second_discount.user_cart_id = 'uniqueId'
    @second_discount.save
    @second_promocode = @second_discount.promocode

    params = {
      data: {
        type: 'carts',
        id: @discount.user_cart_id
      }
    }

    post '/api/v1/carts/redeem', params: params, headers: authorization_header

    expect(response).to have_http_status(200)

    expect(Redemption.all.count).to eql(1)
    redemption = Redemption.first
    expect(redemption.promocodes.count).to eql(2)
    expect(redemption.promocodes.first).to eql(@promocode)
    expect(redemption.promocodes.last).to eql(@second_promocode)
  end

  it 'should provide an error if we pass in a cart that has not been previously priced and has no discount record' do
    params = {
      data: {
        type: 'carts',
        id: 'We\'ve never priced this cart before'
      }
    }

    post '/api/v1/carts/redeem', params: params, headers: authorization_header

    expect(response).to have_http_status(422)

    expect(json['errors'][0]['title']).to eq('This cart has not been priced for a promocode with this service before, therefore we can\'t redeem it')
  end
end