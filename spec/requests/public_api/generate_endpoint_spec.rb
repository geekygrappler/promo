require 'rails_helper'
include Constraints

describe 'Generate endpoint:', type: :request do
  let(:promotion_name) {'Test'}
  let(:start_date) {DateTime.now.utc.iso8601}
  let(:end_date) {(DateTime.now + 60).utc.iso8601}
  let(:user) {User.create(email: 'test@test.com')}
  let(:api_key) {ApiKey.create(user: user)}
  let(:authorization_header) {
    {
      Authorization: api_key.access_token
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

  describe 'a promotion' do
    it 'should generate a new promocode' do
      params = {
        data: {
          type: 'promocodes',
          relationships: {
            promotion: {
              type: 'promotions',
              id: @promotion.id
            }
          }
        }
      }

      post '/api/v1/promocodes/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(201)

      promocode = Promocode.first

      expect(Promocode.all.count).to eq(1)
      expect(promocode.promotion).to eq(@promotion)
      expect(json['data']['id'].to_i).to eq(promocode.id)
      expect(json['data']['attributes']['code']).to eq(promocode.code)
    end
  end

  describe 'SpecificCustomer promotions' do
    before(:each) do
      @promotion.add_constraint 'SpecificCustomerConstraint'
      @promotion.save
    end
    it 'should generate a new promocode when given a customer email' do
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            customer_email: customer_email
          },
          relationships: {
            promotion: {
              type: 'promotions',
              id: @promotion.id
            }
          }
        }
      }

      post '/api/v1/promocodes/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(201)

      promocode = Promocode.first
      expect(json_api_attributes['customer_email']).to eq(promocode.customer_email)
    end
    it 'should respond with an error if no customer email is provided' do
      params = {
        data: {
          type: 'promocodes',
          relationships: {
            promotion: {
              type: 'promotions',
              id: @promotion.id
            }
          }
        }
      }

      post '/api/v1/promocodes/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(422)

      expect(json['errors'][0]['title']).to eq('This promotion requires a customer email, please supply one')
    end
  end

  describe 'OnePerCustomer promotions' do
    before(:each) do
      @promotion.add_constraint 'OnePerCustomerConstraint'
      @promotion.save
    end
    it 'should generate a promocode for a customer' do
      params = {
        data: {
          type: 'promocodes',
          relationships: {
            promotion: {
              type: 'promotions',
              id: @promotion.id
            }
          }
        }
      }

      post '/api/v1/promocodes/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(201)

      promocode = Promocode.first
      expect(json_api_attributes['customer_email']).to eq(promocode.customer_email)
    end
    it 'should respond with an error if there is already a promocode with the same code' do
      Promocode.create(
        code: 'xyz',
        promotion: @promotion
      )

      params = {
        data: {
          type: 'promocodes',
          attributes: {
            code: 'xyz'
          },
          relationships: {
            promotion: {
              type: 'promotions',
              id: @promotion.id
            }
          }
        }
      }

      post '/api/v1/promocodes/generate', params: params, headers: authorization_header

      expect(json['errors'][0]['title']).to eq('This promotion already has a promocode with this code')
    end
  end

  describe 'SinglePromocode promotion' do
    before(:each) do
      @promotion.add_constraint 'SinglePromocodeConstraint'
      @promotion.save
    end
    it 'should generate a promocode' do
      params = {
        data: {
          type: 'promocodes',
          relationships: {
            promotion: {
              type: 'promotions',
              id: @promotion.id
            }
          }
        }
      }

      post '/api/v1/promocodes/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(201)

      expect(Promocode.all.count).to eq(1)
      expect(json_api_attributes['code']).to eq(Promocode.first.code)
    end
    it 'should respond with an error if the promotion already has a promocode' do
      Promocode.create(
        {
          code: 'xyz123',
          promotion: @promotion
        }
      )

      params = {
        data: {
          type: 'promocodes',
          relationships: {
            promotion: {
              type: 'promotions',
              id: @promotion.id
            }
          }
        }
      }

      post '/api/v1/promocodes/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(422)

      expect(json['errors'][0]['title']).to eq('This promotion is limited to one promocode and already has one')
    end
  end

  describe 'Promotion period constraints on promotion' do
    it 'should prevent a promocode being generated after the promotion has ended' do
      @promotion.start_date = (DateTime.now - 20).utc.iso8601
      @promotion.end_date = (DateTime.now - 2).utc.iso8601
      @promotion.save

      params = {
        data: {
          type: 'promocodes',
          relationships: {
            promotion: {
              type: 'promotions',
              id: @promotion.id
            }
          }
        }
      }

      post '/api/v1/promocodes/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(422)

      expect(json['errors'][0]['title']).to eq('This promotion has ended')
    end

    it 'should allow a promocode to be generated before it has started' do
      @promotion.start_date = (DateTime.now + 1).utc.iso8601
      @promotion.save

      params = {
        data: {
          type: 'promocodes',
          relationships: {
            promotion: {
              type: 'promotions',
              id: @promotion.id
            }
          }
        }
      }

      post '/api/v1/promocodes/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(201)

      expect(Promocode.all.count).to eq(1)
      expect(json_api_attributes['code']).to eq(Promocode.first.code)
    end
  end
end
