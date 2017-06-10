require 'rails_helper'
include Constraints
include Modifiers

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

    Promocode.create(
      code: code,
      customer_email: 'hodder@winterfell.com',
      promotion_id: @promotion.id
    )
  end

  describe 'Constraints:' do
    describe 'SpecificCustomer promotions' do
      before(:each) do
        @promotion.add_constraint SpecificCustomerConstraint.new
        @promotion.save
      end
      it 'should return a price when the correct customer email is passed' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code,
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
        @promotion.add_constraint(MinimumBasketTotalConstraint.new(67))
        @promotion.save
      end
      it 'should price a cart that equals or exceeds the minimum basket total' do
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
              'item-total': 60,
              'delivery-total': 7
            }
          }
        }

        get '/api/v1/price', params: params, headers: authorization_header

        expect(response).to have_http_status(200)

        expect(json_api_attributes['total'].to_i).to eq(67)
        expect(json_api_attributes['item-total'].to_i).to eq(60)
        expect(json_api_attributes['delivery-total'].to_i).to eq(7)
      end

      it 'should not price a cart that is less than the minimum basket total' do
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
              'item-total': 60,
              'delivery-total': 6
            }
          }
        }

        get '/api/v1/price', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors'][0]['title']).to eq('This promotion requires a minimum basket total of £67, the current basket is only £66')
      end
    end
  end

  describe 'Modifiers:' do
    describe 'PercentaeItemsModifier' do
      before(:each) do
        @promotion.add_modifier(PercentageItemsModifier.new(20))
        @promotion.save
      end
      it 'should return a correctly discounted cart' do
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
              'item-total': 100,
              'delivery-total': 13
            }
          }
        }

        get '/api/v1/price', params: params, headers: authorization_header

        expect(response).to have_http_status(200)

        expect(json['data']['type']).to eq('prices')
        expect(json_api_attributes['original-item-total'].to_i).to eq(100)
        expect(json_api_attributes['discounted-item-total'].to_i).to to eq(80)
        expect(json_api_attributes['item-discount'].to_i).to eq(20)
        expect(json_api_attributes['original-delivery-total'].to_i).to eq(13)
        expect(json_api_attributes['discounted-delivery-total'].to_i).to eq(13)
        expect(json_api_attributes['delivery-discount'].to_i).to eq(0)
        expect(json_api_attributes['original-total'].to_i).to eq(113)
        expect(json_api_attributes['discounted-total'].to_i).to eq(93)
        expect(json_api_attributes['total-discount'].to_i).to eq(20)
      end
    end

    describe 'PercentageItemsModifier AND PercentageDeliveryModifier' do
      before(:each) do
        @promotion.add_modifier(PercentageItemsModifier.new(10))
        @promotion.add_modifier(PercentageDeliveryModifier.new(100))
        @promotion.save
      end

      it 'should return a correctly discounted cart' do
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
              'item-total': 100,
              'delivery-total': 13
            }
          }
        }

        get '/api/v1/price', params: params, headers: authorization_header

        expect(response).to have_http_status(200)

        expect(json['data']['type']).to eq('prices')
        expect(json_api_attributes['original-item-total'].to_i).to eq(100)
        expect(json_api_attributes['discounted-item-total'].to_i).to to eq(90)
        expect(json_api_attributes['item-discount'].to_i).to eq(10)
        expect(json_api_attributes['original-delivery-total'].to_i).to eq(13)
        expect(json_api_attributes['discounted-delivery-total'].to_i).to eq(0)
        expect(json_api_attributes['delivery-discount'].to_i).to eq(13)
        expect(json_api_attributes['original-total'].to_i).to eq(113)
        expect(json_api_attributes['discounted-total'].to_i).to eq(90)
        expect(json_api_attributes['total-discount'].to_i).to eq(23)
      end

      xit 'should return two errors with explanations if item-total and delivery-total are not supplied in the request' do
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
              'total': 113
            }
          }
        }

        expect(json['errors'][0]['title']).to match('This promocode requires an item total to be passed in the request')
        expect(json['errors'][1]['title']).to match('This promocode requires a deliver total to be passed in the request')
      end
    end
  end
end