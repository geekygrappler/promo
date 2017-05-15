require 'rails_helper'
require 'date'

describe 'Promotions API', type: :request do
    it 'returns the correct status code and the promotion object' do
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

        post '/api/v1/promotions', params: params

        expect(response).to have_http_status(201)

        puts "Hello"
        puts params[:data][:attributes]
        puts "Json:"
        puts json['data']['attributes']

        expect(json['data']['attributes']['name']).to eq(params[:data][:attributes][:name])
        expect(DateTime.parse(json['data']['attributes']['start-date'])).to eq(params[:data][:attributes][:start_date])
        expect(DateTime.parse(json['data']['attributes']['end-date'])).to eq(params[:data][:attributes][:end_date])
    end
end
