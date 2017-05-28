require 'rails_helper'

RSpec.describe 'Promocode public endpoint -', type: :request do
  let(:promotion_name) { 'Test' }
  let(:start_date) { DateTime.now.utc.iso8601 }
  let(:end_date) { (DateTime.now + 60).utc.iso8601 }
  let(:user) { User.create(email: 'test@test.com')}
  let(:api_key) { ApiKey.create(user: user)}
  let(:customer_email) { 'customer@test.com' }
  let(:authorization_header) {
    {
        'Authorization': api_key.access_token
    }
  }

  before(:each) do
    @promotion = Multiple.create(
        name: promotion_name,
        start_date: start_date,
        end_date: end_date,
        user: user
    )
  end

  describe 'Generate Promocode for Multiple Promotions' do
    it 'should generate a new promocode' do
      params = {
          data: {
              type: 'generate-promocode-request',
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

    describe 'for specific customer' do
      it 'should generate a new promocode with a customer email' do
        params = {
            data: {
                type: 'generate-promocode-request',
                attributes: {
                    'promotion-id': @promotion.id,
                    'customer-email': customer_email
                }
            }
        }

        post '/api/v1/generate', params: params, headers: authorization_header

        expect(response).to have_http_status(201)

        promocode = Promocode.first

        expect(json['data']['attributes']['customer_email']).to eq(promocode.customer_email)
      end
      xit 'should respond with an error if no customer email is provided' do
        params = {
            data: {
                type: 'generate-promocode-request',
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
      xit 'should repsond with an error if the customer already has a promocode' do

      end
    end
  end
end
