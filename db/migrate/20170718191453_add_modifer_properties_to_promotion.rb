class AddModiferPropertiesToPromotion < ActiveRecord::Migration[5.1]
  def change
    change_table :promotions do |t|
      t.column :items_percentage_discount, :decimal, precision: 100, scale: 2
      t.column :delivery_percentage_discount, :decimal, precision: 100, scale: 2
      t.column :total_percentage_discount, :decimal, precision: 100, scale: 2
      t.column :items_absolute_discount, :decimal, precision: 100, scale: 2
      t.column :delivery_absolute_discount, :decimal, precision: 100, scale: 2
      t.column :total_absolute_discount, :decimal, precision: 100, scale: 2
    end
  end
end
