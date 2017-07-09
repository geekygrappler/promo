class Api::V1::Promocodes::PublicPromocodesController < ApplicationController
  include Authorisation
  include JsonApi

  before_action :set_user_from_access_token, only: [:generate, :price]
  before_action :set_promocode, :set_cart, only: [:price]
  before_action :set_promocode_validator, only:[:generate, :price]

  # POST '/api/v1/promocodes/generate'
  # Generate a promocode for a Multiple Promotion
  def generate
    @promocode = Promocode.new(promocode_attributes)
    @promocode.promotion = Promotion.find(promotion_params[:id])

    @promocode_validator.validate_generation(@promocode, promocode_attributes)

    if @promocode_validator.valid?
      if promocode_attributes.nil? or promocode_attributes[:code].nil?
        @promocode.code = @promocode.generate_code
      end
      if @promocode.save
        render json: @promocode, status: :created
      else
        render json: @promocode.errors, status: :unprocessable_entity
      end
    else
      render json: json_api_error_response(@promocode_validator.errors), status: :unprocessable_entity
    end
  end

  # POST '/api/v1/promocodes/price'
  # Price a cart based on a promotion that owns the passed in promocode
  def price
    # binding.pry
    @promocode_validator.validate_pricing(@promocode, promocode_attributes, @cart)

    if !@promocode_validator.valid?
      render json: json_api_error_response(@promocode_validator.errors), status: :unprocessable_entity and return
    end

    @cart_validator = CartValidator.new

    # binding.pry
    @cart_validator.validate(@promocode, @cart)

    if !@cart_validator.valid?
      render json: json_api_error_response(@cart_validator.errors), status: :unprocessable_entity and return
    end

    if @promocode_validator.valid? && @cart_validator.valid?
      # TODO wrap in begin rescue. Should never have this failing as the promocode & cart are valid so throw a 500
      @cart_pricer = CartPricer.new
      @discounted_cart = @cart_pricer.price(@cart, @promocode)
      if @discounted_cart
        create_discount
        render json: price_response, status: :ok
      else
        # Should not get here but I'm sure there is a way ;-)
        render json: {
          errors: [
            {
              title: 'Server failed to price the cart :-('
            }
          ]
        }, status: :internal_server_error
      end
    end
  end

  private

  def promocode_params
    # Doesn't have to require attributes because some promocodes can be generated without any
    # attributes, just a reference to a promotion.
    params
      .require(:data)
      .permit(attributes: [:customer_email, :code])
  end

  def promocode_attributes
    promocode_params[:attributes]
  end

  def cart_params
    params
      .require(:data)
      .require(:relationships)
      .require(:cart)
      .require(:attributes)
      .permit(:item_total, :delivery_total, :user_cart_id)
  end

  def promotion_params
    params
      .require(:data)
      .require(:relationships)
      .require(:promotion)
      .permit(:id)
  end

  def set_promocode
    @promocode = Promocode.find_by_code(promocode_attributes[:code])
  end

  def set_cart
    @cart = Cart.new(cart_params)
    @cart.user_cart_id = params[:data][:relationships][:cart][:id]
  end

  def set_promocode_validator
    @promocode_validator = PromocodeValidator.new
  end

  def create_discount
    @cart.save
    @discounted_cart.save
    @discount = Discount.find_or_initialize_by(user_cart_id: @cart.user_cart_id)
    # If we're applying a different promocode we need a new Discount.
    if (@discount.promocode != @promocode)
      @discount = Discount.new(user_cart_id: @cart.user_cart_id)
    end
    @discount.update_attributes(promocode: @promocode, original_cart: @cart, discounted_cart: @discounted_cart)
    @discount.save
  end

  def price_response
    response_attrs = @cart_pricer.price_difference(@cart, @discounted_cart)

    # TODO include our original cart and our new cart for debugging purposes (in dev maybe)
    price_response = {
      data: {
        type: 'prices',
        attributes: hyphenate(response_attrs)
      }
    }
  end
end