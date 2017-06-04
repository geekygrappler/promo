require 'rails_helper'

describe 'price endpoint', type: :request do
  let(:promotion_name) {'Test'}
  let(:start_date) {DateTime.now.utc.iso8601}
  let(:end_date) {(DateTime.now + 60).utc.iso8601}
  let(:user) {User.create(email: 'test@test.com')}
  let(:api_key) {ApiKey.create(user: user)}
  let(:authorization_header) {
    {
      'Authorization': api_key.access_token
    }
  }
  describe 'SpecificCustomer promotions' do
    before(:each) do
      @promotion = Promotion.create(
        name: promotion_name,
        start_date: start_date,
        user: user
      )

      @promotion.add_constraint 'SpecificCustomer'
      @promotion.save

      Promocode.create(
        code: 'xyz123',
        customer_email: 'hodder@winterfell.com',
        promotion_id: @promotion.id
      )
    end
    it 'should return a price when the correct customer email is passed' do
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            code: 'xyz123',
            'customer-email': 'hodder@winterfell.com'
          }
        },
        included: {
          type: 'carts',
          attributes: {
            'item-total': 27,
            'delivery-total': 7
          }
        }
      }

      get '/api/v1/price', params: params, headers: authorization_header

      expect(response).to have_http_status(200)

      expect(json_api_attributes['total'].to_i).to eq(34)
      expect(json_api_attributes['item-total'].to_i).to eq(27)
      expect(json_api_attributes['delivery-total'].to_i).to eq(7)
    end

    it 'should return an error when the wrong customer email is passed' do
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            code: 'xyz123',
            'customer-email': 'theon@pyke.com'
          }
        },
        included: {
          type: 'carts',
          attributes: {
            'total': 39
          }
        }
      }

      get '/api/v1/price', params: params, headers: authorization_header

      expect(response).to have_http_status(422)

      expect(json['errors'][0]['title']).to match('This promocode doens\'t belong to this customer')
    end

    it 'should return an error when no customer email is passed' do
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            code: 'xyz123'
          }
        },
        included: {
          type: 'carts',
          attributes: {
            'total': 39
          }
        }
      }

      get '/api/v1/price', params: params, headers: authorization_header

      expect(response).to have_http_status(422)

      expect(json['errors'][0]['title']).to match('This promotion requires a customer email address')

    end
  end
end