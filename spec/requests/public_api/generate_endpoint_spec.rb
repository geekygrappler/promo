require 'rails_helper'

describe 'generate endpoint', type: :request do
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
  let(:customer_email) {'customer@test.com'}

  before(:each) do
    @promotion = Promotion.create(
      name: promotion_name,
      start_date: start_date,
      end_date: end_date,
      user: user
    )
  end

  describe 'generating a promocode' do
    it 'should generate a new promocode' do
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            'promotion-id': @promotion.id
          }
        }
      }

      post '/api/v1/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(201)

      promocode = Promocode.first

      expect(Promocode.all.count).to eq(1)
      expect(promocode.promotion).to eq(@promotion)
      expect(json['data']['id'].to_i).to eq(promocode.id)
      expect(json['data']['attributes']['code']).to eq(promocode.code)
    end

    describe 'for SpecificCustomer constraint' do
      before(:each) do
        @promotion.add_constraint 'SpecificCustomer'
        @promotion.save
      end
      it 'should generate a new promocode with a customer email' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              'promotion-id': @promotion.id,
              'customer-email': customer_email
            }
          }
        }

        post '/api/v1/generate', params: params, headers: authorization_header

        expect(response).to have_http_status(201)

        promocode = Promocode.first
        expect(json['data']['attributes']['customer-email']).to eq(promocode.customer_email)
      end

      it 'should respond with an error if no customer email is provided' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              'promotion-id': @promotion.id
            }
          }
        }

        post '/api/v1/generate', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors']['title']).to eq('This promotion requires a customer email address')
      end
    end
    describe 'for UniqueCustomerGeneration constraint' do
      it 'should respond with an error if the customer already has a promocode and the promotion is restricted to
            once per customer' do
        @promotion.add_constraint 'UniqueCustomerGeneration'
        @promotion.save
        @promotion.generate_promocode('billy@blogs.com').save

        params = {
          data: {
            type: 'promocodes',
            attributes: {
              'promotion-id': @promotion.id,
              'customer-email': 'billy@blogs.com'
            }
          }
        }

        post '/api/v1/generate', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors']['title']).to eq('This customer already has a promocode for this promotion, and it\'s limited to one per customer')
      end
    end

    describe 'for SinglePromocode constraint' do
      it 'should respond with an error if the promotion already has a promocode' do
        @promotion.add_constraint 'SinglePromocode'
        @promotion.save
        @promotion.generate_promocode.save

        params = {
          data: {
            type: 'promocodes',
            attributes: {
              'promotion-id': @promotion.id,
            }
          }
        }

        post '/api/v1/generate', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors']['title']).to eq('This promotion is limited to one promocode and already has one')
      end
    end
  end
end
