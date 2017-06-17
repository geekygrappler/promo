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

  describe 'a promotion' do
    it 'should generate a new promocode' do
      params = {
        data: {
          type: 'promocodes',
        },
        included: {
          type: 'promotion',
          id: @promotion.id
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
  end

  describe 'SpecificCustomer promotions' do
    before(:each) do
      @promotion.add_constraint SpecificCustomerConstraint.new
      @promotion.save
    end
    it 'should generate a new promocode when given a customer email' do
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            customer_email: customer_email
          }
        },
        included: {
          type: 'promotions',
          id: @promotion.id
        }
      }

      post '/api/v1/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(201)

      promocode = Promocode.first
      expect(json_api_attributes['customer-email']).to eq(promocode.customer_email)
    end
    it 'should respond with an error if no customer email is provided' do
      params = {
        data: {
          type: 'promocodes'
        },
        included: {
          type: 'promotions',
          id: @promotion.id
        }
      }

      post '/api/v1/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(422)

      expect(json['errors'][0]['title']).to eq('This promotion requires a customer email, please supply one')
    end
  end

  describe 'UniqueCustomerGeneration promotions' do
    before(:each) do
      @promotion.add_constraint UniqueCustomerGenerationConstraint.new
      @promotion.save
    end
    it 'should generate a promocode for a customer' do
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            customer_email: customer_email
          }
        },
        included: {
          type: 'promotions',
          id: @promotion.id
        }
      }

      post '/api/v1/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(201)

      promocode = Promocode.first
      expect(json_api_attributes['customer-email']).to eq(promocode.customer_email)
    end
    it 'should respond with an error if the customer already has a promocode and the promotion is restricted to
          once promocode per customer' do
      Promocode.create(
        {
          code: 'xyz123',
          customer_email: 'billy@blogs.com',
          promotion: @promotion
        }
      )

      params = {
        data: {
          type: 'promocodes',
          attributes: {
            customer_email: 'billy@blogs.com'
          }
        },
        included: {
          type: 'promotions',
          id: @promotion.id
        }
      }

      post '/api/v1/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(422)

      expect(json['errors'][0]['title']).to eq('This customer already has a promocode for this promotion, and it\'s limited to one per customer')
    end
  end

  describe 'SinglePromocode promotion' do
    before(:each) do
      @promotion.add_constraint SinglePromocodeConstraint.new
      @promotion.save
    end
    it 'should generate a promocode' do
      params = {
        data: {
          type: 'promocodes'
        },
        included: {
          type: 'promotions',
          id: @promotion.id
        }
      }

      post '/api/v1/generate', params: params, headers: authorization_header

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
        },
        included: {
          type: 'promotions',
          id: @promotion.id
        }
      }

      post '/api/v1/generate', params: params, headers: authorization_header

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
        },
        included: {
          type: 'promotions',
          id: @promotion.id
        }
      }

      post '/api/v1/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(422)

      expect(json['errors'][0]['title']).to eq('This promotion has ended')
    end

    # TODO this is wrong. We should allow promocodes to be generated before the promotion starts
    it 'should prevent a promocode being generate before it has started' do
      @promotion.start_date = (DateTime.now + 1).utc.iso8601
      @promotion.save

      params = {
        data: {
          type: 'promocodes',
        },
        included: {
          type: 'promotions',
          id: @promotion.id
        }
      }

      post '/api/v1/generate', params: params, headers: authorization_header

      expect(response).to have_http_status(422)

      expect(json['errors'][0]['title']).to eq("This promotion has not started, it starts on #{@promotion.start_date.to_s}")
    end
  end
end
