class Api::V1::PromotionsController < ApplicationController
  before_action :set_user_from_access_token, only: [:create]

  def create
    @promotion = Promotion.new(promotion_params)
    @promotion.user = @user
    if @promotion.save
      render json: @promotion, status: :created
    else
      render json: @promotion.errors, status: :bad_request
    end
  end

  private

  def promotion_params
    params.require(:data).require(:attributes).permit(:name, :start_date, :end_date)
  end

  def set_user_from_access_token
    api_key = ApiKey.find_by(access_token: request.headers['Authorization'])

    if api_key.nil?
      render json: {
        errors: {
          title: 'API key is not valid'
        }
      }, status: :unauthorized
    else
      @user = api_key.user
    end
  end
end
