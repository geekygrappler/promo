require 'rails_helper'
require 'date'

RSpec.describe 'Promotions API', type: :request do
  describe 'token access' do
    it 'creates a promotion when a valid access_token is provided' do
      PROMOTION_NAME = 'Test'
      START_DATE = DateTime.now.utc.iso8601
      END_DATE = (DateTime.now + 60).utc.iso8601

      user = User.create(email: 'test@test.com')
      api_key = ApiKey.create(user: user)

      params = {
          data: {
              type: 'promotions',
              attributes: {
                  name: 'Test',
                  start_date: START_DATE,
                  end_date: END_DATE
              }
          }
      }

      headers = {
        'Authorization': api_key.access_token
      }

      post '/api/v1/promotions', params: params, headers: headers

      expect(response).to have_http_status(201)

      expect(json['data']['attributes']['name']).to eq(PROMOTION_NAME)
      expect(DateTime.parse(json['data']['attributes']['start-date'])).to eq(START_DATE)
      expect(DateTime.parse(json['data']['attributes']['end-date'])).to eq(END_DATE)
    end

    it 'tells the client that the token is not recognised' do

      headers = {
        'Authorization': 'Some bollocks'
      }

      post '/api/v1/promotions', headers: headers

      expect(response).to have_http_status(401)

      expect(json['errors']['title']).to eq('API key is not valid')
    end
  end

  describe 'partially incomplete requests' do
    it 'should allow no end date to be supplied' do
      PROMOTION_NAME = 'Test'
      START_DATE = DateTime.now.utc.iso8601

      user = User.create(email: 'test@test.com')
      api_key = ApiKey.create(user: user)

      params = {
          data: {
              type: 'promotions',
              attributes: {
                  name: PROMOTION_NAME,
                  start_date: START_DATE,
                  end_date: nil
              }
          }
      }

      headers = {
        'Authorization': api_key.access_token
      }

      post '/api/v1/promotions', params: params, headers: headers

      expect(response).to have_http_status(201)

      expect(json['data']['attributes']['name']).to eq(PROMOTION_NAME)
      expect(DateTime.parse(json['data']['attributes']['start-date'])).to eq(START_DATE)
      expect(json['data']['attributes']['end-date']).to eq(nil)
    end
  end
end
