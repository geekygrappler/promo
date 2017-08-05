class PromotionsController < ApplicationController
  def index
    @promotions = current_user.promotions
    render json: @promotions
  end
end
