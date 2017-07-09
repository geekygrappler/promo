class CreateRedemptions < ActiveRecord::Migration[5.1]
  def change
    create_table :redemptions do |t|
      t.string :user_cart_id

      t.timestamps
    end
  end
end
