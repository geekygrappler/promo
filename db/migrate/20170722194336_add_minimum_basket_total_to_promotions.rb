class AddMinimumBasketTotalToPromotions < ActiveRecord::Migration[5.1]
  def change
    add_column :promotions, :minimum_basket_total, :decimal, precision: 100, scale: 2
  end
end
