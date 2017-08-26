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
        @promotion.add_constraint 'SpecificCustomerConstraint'
      end
      it 'should return a price when the correct customer email is passed' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code,
              customer_email: 'hodder@winterfell.com'
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  item_total: 27,
                  delivery_total: 7
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(200)

        expect(Discount.count).to be(1)

        expect(json_api_attributes['discounted-total']).to eq('34.0')
        expect(json_api_attributes['discounted-item-total']).to eq('27.0')
        expect(json_api_attributes['discounted-delivery-total']).to eq('7.0')
      end

      it 'should return an error when the wrong customer email is passed' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code,
              customer_email: 'theon@pyke.com'
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  item_total: 99,
                  delivery_total: 9
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors'][0]['title']).to match('This promocode doesn\'t belong to this customer')
      end

      it 'should return an error when no customer email is passed' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  total: 39
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors'][0]['title']).to match('This promotion requires a customer email, please supply one')

      end
    end

    describe 'OnePerCustomerConstraint promotion' do
      before(:each) do
        @promotion.add_constraint 'OnePerCustomerConstraint'
      end
      it 'should return a price when priced' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code,
              customer_email: 'brownbear@bo.com'
            },
            relationships: {
              cart: {
                type: 'carts',
                id: 'CartId',
                attributes: {
                  item_total: 27,
                  delivery_total: 7
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(200)

        expect(Discount.count).to be(1)

        expect(json_api_attributes['discounted-total']).to eq('34.0')
        expect(json_api_attributes['discounted-item-total']).to eq('27.0')
        expect(json_api_attributes['discounted-delivery-total']).to eq('7.0')
      end
      it 'should prevent a promocode being used if we already have a redemption for that user' do
        Redemption.create(user_cart_id: 'CartId')

        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code,
              customer_email: 'brownbear@bo.com'
            },
            relationships: {
              cart: {
                type: 'carts',
                id: 'CartId',
                attributes: {
                  total: 39
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(json['errors'][0]['title']).to match(
          'You have already redeemed this discount and it\'s limited to one use per person'
        )
      end

      it 'should create a discount recor'
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
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  item_total: 27,
                  delivery_total: 7
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

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
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  item_total: 27,
                  delivery_total: 7
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors'][0]['title']).to eq("This promotion has not started, it starts on #{@promotion.start_date.to_s}")
      end
    end

    describe 'MinimumBasketTotal promotions' do
      before(:each) do
        @promotion.add_constraint('MinimumBasketTotalConstraint', { minimum_basket_total: 67 })
      end
      it 'should price a cart that equals or exceeds the minimum basket total' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  item_total: 60,
                  delivery_total: 7
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(200)

        expect(json_api_attributes['discounted-total']).to eq('67.0')
        expect(json_api_attributes['discounted-item-total']).to eq('60.0')
        expect(json_api_attributes['discounted-delivery-total']).to eq('7.0')
      end

      it 'should not price a cart that is less than the minimum basket total' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  item_total: 60,
                  delivery_total: 6
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors'][0]['title']).to eq('This promotion requires a minimum basket total of 67.0, the current basket is only 66.0')
      end
    end
  end

  describe 'Modifiers:' do
    describe 'ItemsPercentageModifier' do
      before(:each) do
        @promotion.add_modifier('ItemsPercentageModifier', { items_percentage_discount: 20 })
      end
      it 'should return a correctly discounted cart' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  item_total: 100,
                  delivery_total: 13
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(200)

        expect(json['data']['type']).to eq('prices')
        expect(json_api_attributes['original-item-total']).to eq('100.0')
        expect(json_api_attributes['discounted-item-total']).to eq('80.0')
        expect(json_api_attributes['item-discount']).to eq('20.0')
        expect(json_api_attributes['original-delivery-total']).to eq('13.0')
        expect(json_api_attributes['discounted-delivery-total']).to eq('13.0')
        expect(json_api_attributes['delivery-discount']).to eq('0.0')
        expect(json_api_attributes['original-total']).to eq('113.0')
        expect(json_api_attributes['discounted-total']).to eq('93.0')
        expect(json_api_attributes['total-discount']).to eq('20.0')
      end

      it 'should return an error if an item_total is not supplied' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  delivery_total: 13
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors'][0]['title']).to eq('This promocode requires an item total to be passed in the request')
      end
    end

    describe 'ItemsPercentageModifier AND DeliveryPercentageModifier' do
      before(:each) do
        @promotion.add_modifier('ItemsPercentageModifier', { items_percentage_discount: 10 })
        @promotion.add_modifier('DeliveryPercentageModifier', { delivery_percentage_discount: 100 })
      end

      it 'should return a correctly discounted cart' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  item_total: 100,
                  delivery_total: 13
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(200)

        expect(json['data']['type']).to eq('prices')
        expect(json_api_attributes['original-item-total']).to eq('100.0')
        expect(json_api_attributes['discounted-item-total']).to eq('90.0')
        expect(json_api_attributes['item-discount']).to eq('10.0')
        expect(json_api_attributes['original-delivery-total']).to eq('13.0')
        expect(json_api_attributes['discounted-delivery-total']).to eq('0.0')
        expect(json_api_attributes['delivery-discount']).to eq('13.0')
        expect(json_api_attributes['original-total']).to eq('113.0')
        expect(json_api_attributes['discounted-total']).to eq('90.0')
        expect(json_api_attributes['total-discount']).to eq('23.0')
      end

      it 'should return two errors with explanations if item-total and delivery-total are not supplied in the request' do
        params = {
          data: {
            type: 'promocodes',
            attributes: {
              code: code
            },
            relationships: {
              cart: {
                type: 'carts',
                attributes: {
                  total: 113
                }
              }
            }
          }
        }

        post '/api/v1/promocodes/price', params: params, headers: authorization_header

        expect(response).to have_http_status(422)

        expect(json['errors'][0]['title']).to match('This promocode requires an item total to be passed in the request')
        expect(json['errors'][1]['title']).to match('This promocode requires a deliver total to be passed in the request')
      end
    end
  end

  describe 'Discount Records' do
    it 'should create a discount record when a cart is priced' do
      @promotion.add_modifier('ItemsPercentageModifier', { items_percentage_discount: 10 })
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            code: code,
            customer_email: 'hodder@winterfell.com'
          },
          relationships: {
            cart: {
              type: 'carts',
              id: 'uniqueId',
              attributes: {
                item_total: 27,
                delivery_total: 7
              }
            }
          }
        }
      }

      post '/api/v1/promocodes/price', params: params, headers: authorization_header

      expect(Discount.first).to be_truthy
      expect(Discount.count).to eql(1)

      expect(Discount.first.original_cart.user_cart_id).to eql(params[:data][:relationships][:cart][:id])
      expect(Discount.first.discounted_cart.user_cart_id).to eql(params[:data][:relationships][:cart][:id])

      expect(Discount.first.discounted_cart.item_total).to eql(24.3)
    end

    it 'should replace an old discount record when a cart is priced again' do
      @promotion.add_modifier('ItemsPercentageModifier', { items_percentage_discount: 10 })
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            code: code,
            customer_email: 'hodder@winterfell.com'
          },
          relationships: {
            cart: {
              type: 'carts',
              id: 'uniqueId',
              attributes: {
                item_total: 27,
                delivery_total: 7
              }
            }
          }
        }
      }

      post '/api/v1/promocodes/price', params: params, headers: authorization_header

      second_params = {
        data: {
          type: 'promocodes',
          attributes: {
            code: code,
            customer_email: 'hodder@winterfell.com'
          },
          relationships: {
            cart: {
              type: 'carts',
              id: 'uniqueId',
              attributes: {
                item_total: 50,
                delivery_total: 7
              }
            }
          }
        }
      }

      post '/api/v1/promocodes/price', params: second_params, headers: authorization_header

      expect(Discount.first).to be_truthy
      expect(Discount.count).to eql(1)

      expect(Discount.first.original_cart.user_cart_id).to eql(params[:data][:relationships][:cart][:id])
      expect(Discount.first.discounted_cart.user_cart_id).to eql(params[:data][:relationships][:cart][:id])

      expect(Discount.first.discounted_cart.item_total).to eql(45)

      expect(Discount.first.updated_at).not_to be_nil
    end

    it 'should be possible to apply multiple codes to a cart and have a separate discount for each promocode' do
      @promotion.add_modifier('ItemsPercentageModifier', { items_percentage_discount: 10 })
      params = {
        data: {
          type: 'promocodes',
          attributes: {
            code: code,
            customer_email: 'hodder@winterfell.com'
          },
          relationships: {
            cart: {
              type: 'carts',
              id: 'uniqueId',
              attributes: {
                item_total: 27,
                delivery_total: 7
              }
            }
          }
        }
      }

      post '/api/v1/promocodes/price', params: params, headers: authorization_header

      second_promotion = Promotion.create(
        name: promotion_name,
        start_date: start_date,
        user: user
      )

      second_promotion.add_modifier('DeliveryPercentageModifier', { delivery_percentage_discount: 20 })

      second_promocode = Promocode.create(
        code: 'hello second code',
        promotion_id: second_promotion.id
      )


      second_params = {
        data: {
          type: 'promocodes',
          attributes: {
            code: 'hello second code',
            customer_email: 'hodder@winterfell.com'
          },
          relationships: {
            cart: {
              type: 'carts',
              id: 'uniqueId',
              attributes: {
                item_total: 24.3,
                delivery_total: 7
              }
            }
          }
        }
      }

      post '/api/v1/promocodes/price', params: second_params, headers: authorization_header

      first_discount = Discount.first
      expect(Discount.count).to eql(2)
      expect(first_discount.original_cart.user_cart_id).to eql(params[:data][:relationships][:cart][:id])
      expect(first_discount.discounted_cart.item_total).to eql(24.3)

      second_discount = Discount.last
      expect(second_discount.original_cart.item_total).to eql(24.3)
      expect(second_discount.discounted_cart.delivery_total).to eql(5.6)

    end
  end
end