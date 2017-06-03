class RemoveTypeFromPromotion < ActiveRecord::Migration[5.1]
  def change
    remove_column :promotions, :type, :string
  end
end
