require 'rails_helper'
include Constraints

describe 'Price endpoint:', type: :request do
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
  let(:code) {'xyz123'}

  before(:each) do
    @promotion = Promotion.create(
      name: promotion_name,
      start_date: start_date,
      user: user
    )
  end

  describe 'Constraints:' do
    describe 'SpecificCustomer promotions' do
      before(:each) do
        @promotion.add_constraint SpecificCustomerConstraint.new
        @promotion.save

        Promocode.create(
          code: code,
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
              code: code,
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
              code: code
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

    describe 'Promotion period constraints on promotions' do
      before(:each) do
        Promocode.create(
          code: code,
          promotion_id: @promotion.id
        )
      end
      it 'should prevent a promocode being used after the promotion has ended' do
        @promotion.start_date = (DateTime.now - 20).utc.iso8601
        @promotion.end_date = (DateTime.now - 2).utc.iso8601
        @promotion.save

        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code
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

        expect(response).to have_http_status(422)

        expect(json['errors'][0]['title']).to eq('This promotion has ended')
      end

      it 'should prevent a promocode being used before it has started' do
        @promotion.start_date = (DateTime.now + 1).utc.iso8601
        @promotion.save

        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code
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

        expect(response).to have_http_status(422)

        expect(json['errors'][0]['title']).to eq("This promotion has not started, it starts on #{@promotion.start_date.to_s}")
      end
    end

    describe 'MinimumBasketTotal promotions' do
      before(:each) do
        @promotion.add_constraint('MinimumBasketTotal')
        @promotion.save
      end
      it 'should price a cart that equals or exceeds the minimum basket total' do
        
      end
    end
  end
end