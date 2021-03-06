class PromotionsController < ApplicationController
  include Authorisation

  before_action :set_user_from_access_token, only: [:destroy]
  def index
    @promotions = current_user.promotions
    render json: @promotions
  end

  def create
    user = current_user
    promotion = Promotion.new(promotion_params)
    promotion.user = user
    render json: promotion if promotion.save
  end

  def show
    promotion = Promotion.find(params[:id])
    render json: promotion
  end

  def destroy
    promotion = Promotion.find(params[:id])
    if promotion.user == @user && promotion.destroy
      render json: promotion, status: :no_content
    else
      # TODO some error
    end
  end

  private

  def promotion_params
    params
      .require(:data)
      .require(:attributes)
      .permit(
        :name,
        :start_date,
        :end_date,
        :items_percentage_discount,
        :delivery_percentage_discount,
        :total_percentage_discount,
        :items_absolute_discount,
        :delivery_absolute_discount,
        :total_absolute_discount,
        :minimum_basket_total,
        constraints: [],
        modifiers: []
      )
  end
end
