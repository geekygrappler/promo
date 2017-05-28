class AddConstraintsToPromotions < ActiveRecord::Migration[5.1]
  def change
    add_column :promotions, :constraints, :string
  end
end
