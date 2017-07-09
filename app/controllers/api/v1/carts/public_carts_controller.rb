class Api::V1::Carts::PublicCartsController < ApplicationController
  include Authorisation
  include JsonApi

  before_action :set_user_from_access_token, only: [:redeem]
  before_action :set_cart, only: [:redeem]

  # POST '/api/v1/carts/redeem'
  # Mark a promocode as redeemed and try to link it to a Discount record
  def redeem
    @redemption = Redemption.new(
      {user_cart_id: @cart.user_cart_id}
    )

    @discounts = find_discount_for_redemption
    @discounts.each do |discount|
      discount.redemption = @redemption
      discount.save
    end

    if @redemption.valid?
      render json: @redemption
    else
      # Should not get here but I'm sure there is a way ;-)
      render json: {
        errors: [
          {
            title: 'Server failed to save redemption :-('
          }
        ]
      }, status: :internal_server_error
    end
  end

  private

  def cart_params
    params
      .require(:data)
      .permit(:id)
  end

  def set_cart
    @cart = Cart.new({user_cart_id: cart_params[:id]})
  end

  # We need the user cart id to link to a Discount record reliably
  #
  # @return [Discount]
  def find_discount_for_redemption
    Discount.where(user_cart_id: @cart.user_cart_id)
  end
end