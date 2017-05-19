require 'rails_helper'
require 'date'

RSpec.describe 'Promotions API', type: :request do
  describe 'token access' do
    it 'creates a promotion when a valid access_token is provided' do
      user = User.create(email: 'test@test.com')
      api_key = ApiKey.create(user: user)

      params = {
          data: {
              type: 'promotions',
              attributes: {
                  name: 'Test',
                  start_date: DateTime.now.utc.iso8601,
                  end_date: (DateTime.now + 60).utc.iso8601
              }
          }
      }

      headers = {
        'Authorization': api_key.access_token
      }

      post '/api/v1/promotions', params: params, headers: headers

      expect(response).to have_http_status(201)

      expect(json['data']['attributes']['name']).to eq(params[:data][:attributes][:name])
      expect(DateTime.parse(json['data']['attributes']['start-date'])).to eq(params[:data][:attributes][:start_date])
      expect(DateTime.parse(json['data']['attributes']['end-date'])).to eq(params[:data][:attributes][:end_date])
    end

    it 'tells the client that the token is not recognised' do
      params = {
          data: {
              type: 'promotions',
              attributes: {
                  name: 'Test',
                  start_date: DateTime.now.utc.iso8601,
                  end_date: (DateTime.now + 60).utc.iso8601
              }
          }
      }

      headers = {
        'Authorization': 'Some bollocks'
      }

      post '/api/v1/promotions', params: params, headers: headers

      expect(response).to have_http_status(401)

      expect(json['errors']['title']).to eq('API key is not valid')
    end
  end
end
