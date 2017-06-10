#TODO once we have a client dealing with CRUD Promocode actions, it will be clear that Public API endpoints do not belong here!

class Api::V1::PromocodesController < ApplicationController
  include Authorisation
  include Pricing

  before_action :set_user_from_access_token, only: [:generate, :price]
  before_action :set_promocode, :set_cart, only: [:price]

  # POST '/api/v#/generate'
  # Generate a promocode for a Multiple Promotion
  def generate
    @promotion = Promotion.find(promocode_params['promotion-id'])
    @promocode = @promotion.generate_promocode(promocode_params)

    # Pretty horrible - generate_promocode returns either a Promocode or an Array of errors
    if !@promocode.is_a?(Promocode)
        render json: {
            errors: @promocode.map { |error|
              {
                title: error.message
              }
            }
        }, status: :unprocessable_entity
    else
      if @promocode.save
        render json: @promocode, status: :created
      else
        render json: @promocode.errors, status: :bad_request
      end
    end
  end

  # GET '/api/v#/price'
  # Price a cart based on a promotion that owns the passed in promocode
  def price
    @promotion = @promocode.promotion

    # begin
    #    get_price
    # rescue e (should be an array of errors)
    #    render json: errors
    # end
    @discounted_cart = @promocode.price_cart(@cart)
    if @promocode
      errors = @promocode.constraint_errors(promocode_params, @cart)
      if errors.any?
        render json: {
          errors: errors.map { |error|
            {
              title: error.message
            }
          }
        }, status: :unprocessable_entity
      else
        render json: price_response, status: :ok
      end
    end
  end

  private
  def promocode_params
    # TODO obviously promotion is a relationship and should be dealt with in a JSON:API way.
    params.require(:data).require(:attributes).permit('promotion-id', 'customer-email', 'code')
  end

  def cart_params
    params.require(:included).require(:attributes).permit('item-total', 'delivery-total', 'total')
  end

  def set_promocode
    @promocode = Promocode.find_by_code(promocode_params['code'])
  end

  def set_cart
    @cart = Cart.new(cart_params)
  end

  def price_response
    response_attrs = price_difference(@cart, @discounted_cart)
    binding.pry
    # TODO include our original cart and our new cart for debugging purposes (in dev maybe)

    #TODO serialize to JSON::API
    price_response = {
      data: {
        type: 'prices',
        attributes: response_attrs
      }
    }
  end

  def cart_total
    if cart_params['total']
      return cart_params['total']
    else
      return cart_params['item-total'].to_i + cart_params['delivery-total'].to_i
    end
  end
end