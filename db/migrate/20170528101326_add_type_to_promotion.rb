class AddTypeToPromotion < ActiveRecord::Migration[5.1]
  def change
    add_column :promotions, :type, :string
  end
end
