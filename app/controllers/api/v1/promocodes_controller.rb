class Api::V1::PromocodesController < ApplicationController
  include Authorisation

  before_action :set_user_from_access_token, only: [:generate]

  # Generate a promocode for a Multiple Promotion
  def generate
    @promotion = Promotion.find(generate_promocode_params['promotion-id'])
    @promocode = Promocode.new(code: ('a'..'z').to_a.shuffle[0,8].join)
    @promocode.customer_email = generate_promocode_params[:customer_email]
    @promocode.promotion = @promotion
    if @promocode.save
      render json: @promocode, status: :created
    else
      render json: @promocode.errors, status: :bad_request
    end
  end

  private
  def generate_promocode_params
    params.require(:data).require(:attributes).permit('promotion-id', :customer_email)
  end
end