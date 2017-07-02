class CreateCarts < ActiveRecord::Migration[5.1]
  def change
    create_table :carts do |t|
      t.decimal :item_total
      t.decimal :delivery_total
      t.string :user_cart_id
      t.text :items

      t.timestamps
    end
  end
end
