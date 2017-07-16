class PromotionsController < ApplicationController
  def index
    @promotions = Promotion.all
    render json: @promotions
  end
end
