class PromocodesHasManyRedemptionsThroughDiscounts < ActiveRecord::Migration[5.1]
  def change
    add_column :discounts, :redemption_id, :bigint
    add_index :discounts, :redemption_id
  end
end
