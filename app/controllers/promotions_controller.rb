class PromotionsController < ApplicationController
  def index
    @promotions = current_user.promotions
    render json: @promotions
  end

  def create
    user = current_user
    promotion = Promotion.new(promotion_params)
    promotion.user = user
    if promotion.save
      render json: promotion
    end
  end

  private

  def promotion_params
    params
      .require(:data)
      .require(:attributes)
      .permit(:name, :constraints, :modifiers, :start_date, :end_date)

  end

end
