#TODO once we have a client dealing with CRUD Promocode actions, it will be clear that Public API endpoints do not belong here!

class Api::V1::PromocodesController < ApplicationController
  include Authorisation
  include Pricing
  include JsonApi

  before_action :set_user_from_access_token, only: [:generate, :price]
  before_action :set_promocode, :set_cart, only: [:price]

  # POST '/api/v#/generate'
  # Generate a promocode for a Multiple Promotion
  def generate
    # @promotion = Promotion.find(promocode_params['promotion-id'])
    # @promocode = @promotion.generate_promocode(promocode_params)
    @promocode = Promocode.new(promocode_attributes)
    @promocode.promotion = Promotion.find(promotion_params[:id])

    validator = PromocodeValidator.new

    validator.validate(@promocode, promocode_attributes)

    if validator.valid?
      if promocode_attributes && promocode_attributes[:code].nil?
        @promocode.code = @promocode.generate_code
      end
      if @promocode.save
        render json: @promocode, status: :created
      else
        render json: @promocode.errors, status: :unprocessable_entity
      end
    else
      render json: json_api_error_response(validator.errors), status: :unprocessable_entity
    end

    # # Pretty horrible - generate_promocode returns either a Promocode or an Array of errors
    # if !@promocode.is_a?(Promocode)
    #     render json: {
    #         errors: @promocode.map { |error|
    #           {
    #             title: error.message
    #           }
    #         }
    #     }, status: :unprocessable_entity
    # else
    #   if @promocode.save
    #     render json: @promocode, status: :created
    #   else
    #     render json: @promocode.errors, status: :bad_request
    #   end
    # end
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
    params.require(:data).permit(attributes: [:customer_email, :code])
  end

  def promocode_attributes
    promocode_params[:attributes]
  end

  def cart_params
    params.require(:included).permit(attributes: [:item_total, :delivery_total, :total])
  end

  def promotion_params
    params.require(:included).permit(:id)
  end

  def set_promocode
    @promocode = Promocode.find_by_code(promocode_params[:code])
  end

  def set_cart
    @cart = Cart.new(cart_params)
  end

  def price_response
    response_attrs = price_difference(@cart, @discounted_cart)

    # TODO include our original cart and our new cart for debugging purposes (in dev maybe)
    price_response = {
      data: {
        type: 'prices',
        attributes: hyphenate(response_attrs)
      }
    }
  end

  def cart_total
    if cart_params[:total]
      return cart_params[:total]
    else
      return cart_params[:item_total].to_i + cart_params[:delivery_total].to_i
    end
  end
end