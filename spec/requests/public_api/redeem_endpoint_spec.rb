require 'rails_helper'

describe 'Redeem endpoint', type: :request do
  let(:promotion_name) { 'Redemption Promotion' }
  let(:start_date) { DateTime.now.utc.iso8601 }
  let(:end_date) { (DateTime.now + 60).utc.iso8601 }
  let(:user) {User.create(email: 'test@test.com')}
  let(:api_key) {ApiKey.create(user: user)}
  let(:authorization_header) {
    {
      'Authorization': api_key.access_token
    }
  }
  let(:code) {'xyz123'}
  let(:user_cart_id) { 'uniqueId' }

  before(:each) do
    @discount = build(:discount)
    @discount.save
    @promocode = @discount.promocode
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
end