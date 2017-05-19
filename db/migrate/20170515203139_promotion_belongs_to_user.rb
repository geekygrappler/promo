class PromotionBelongsToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :promotions, :user, foreign_key: true
  end
end
