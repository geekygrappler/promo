class Api::V1::PromotionsController < ApplicationController
  include Authorisation

  before_action :set_user_from_access_token, only: [:create]
  before_action :create_promotion, only: [:create]

  def create
    @promotion.user = @user
    if @promotion.save
      render json: @promotion, status: :created
    else
      render json: @promotion.errors, status: :bad_request
    end
  end

  private

  def promotion_params
    params.require(:data).require(:attributes).permit(:name, :start_date, :end_date, :promotion_type)
  end

  def create_promotion
    if (promotion_params[:promotion_type] === 'single')
      single_params = promotion_params
      single_params.delete('promotion_type')
      @promotion = Single.new(single_params)
    else
      multiple_params = promotion_params
      multiple_params.delete('promotion_type')
      @promotion = Multiple.new(multiple_params)
    end
  end
end
