class AddModifiersToPromotions < ActiveRecord::Migration[5.1]
  def change
    add_column :promotions, :modifiers, :string
  end
end
