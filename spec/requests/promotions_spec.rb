require 'rails_helper'
require 'date'

RSpec.describe 'Promotions API', type: :request do

  # Constants for tests
  let(:promotion_name) { 'Test' }
  let(:start_date) { DateTime.now.utc.iso8601 }
  let(:end_date) { (DateTime.now + 60).utc.iso8601 }
  let(:default_params) {
    {
        data: {
            type: 'promotions',
            attributes: {
                name: promotion_name,
                start_date: start_date,
                end_date: end_date
            }
        }
    }
  }
  let(:user) { User.create(email: 'test@test.com')}
  let(:api_key) { ApiKey.create(user: user)}
  let(:authorization_header) {
    {
        'Authorization': api_key.access_token
    }
  }


  describe 'token access' do
    it 'creates a promotion when a valid access_token is provided' do

      post '/api/v1/promotions', params: default_params, headers: authorization_header

      expect(response).to have_http_status(201)

      expect(json['data']['attributes']['name']).to eq(promotion_name)
      expect(DateTime.parse(json['data']['attributes']['start-date'])).to eq(start_date)
      expect(DateTime.parse(json['data']['attributes']['end-date'])).to eq(end_date)
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
      default_params[:data][:attributes][:end_date] = nil

      post '/api/v1/promotions', params: default_params, headers: authorization_header

      expect(response).to have_http_status(201)

      expect(json['data']['attributes']['end-date']).to eq(nil)
    end

    it 'should allow no start date and set it to right now' do
      default_params[:data][:attributes][:start_date] = nil

      post '/api/v1/promotions', params: default_params, headers: authorization_header

      expect(response).to have_http_status(201)

      expect(Time.parse(json['data']['attributes']['start-date']).to_s).to eq(Time.now.utc.to_s)
    end
  end
end
