class Api::V1::PromotionsController < ApplicationController
  include Authorisation

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
end
