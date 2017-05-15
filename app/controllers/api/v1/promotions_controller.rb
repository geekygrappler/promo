class Api::V1::PromotionsController < ApplicationController
  def create
    @promotion = Promotion.new(promotion_params)
    @promotion.save do
      render json: @promotion, status: :created
    end
  end

  private

  def promotion_params
    params.require(:data).require(:attributes).permit(:name, :start_date, :end_date)
  end
end
