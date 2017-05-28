class CreatePromocodes < ActiveRecord::Migration[5.1]
  def change
    create_table :promocodes do |t|
      t.string :code
      t.string :customer_email
      t.belongs_to :promotion, index: true

      t.timestamps
    end
  end
end
