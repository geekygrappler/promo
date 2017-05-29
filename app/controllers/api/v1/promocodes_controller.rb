class Api::V1::PromocodesController < ApplicationController
  include Authorisation
  include Constraints

  before_action :set_user_from_access_token, only: [:generate]

  # Generate a promocode for a Multiple Promotion
  def generate
    @promotion = Promotion.find(promocode_params['promotion-id'])
    @promocode = @promotion.generate_promocode(promocode_params['customer-email'])

    # Pretty horrible
    if @promocode.is_a?(ConstraintError)
        render json: {
            errors: {
                title: @promocode.message
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

  private
  def promocode_params
    params.require(:data).require(:attributes).permit('promotion-id', 'customer-email')
  end
end