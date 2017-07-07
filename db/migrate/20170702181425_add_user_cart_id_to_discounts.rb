class AddUserCartIdToDiscounts < ActiveRecord::Migration[5.1]
  def change
    add_column :discounts, :user_cart_id, :string
  end
end
