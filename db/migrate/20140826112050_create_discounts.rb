class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
      t.belongs_to :discount_type
      t.belongs_to :shop
      t.string :title
      t.text :content
      t.decimal :price
      t.float :discount
      t.boolean :hot
      t.timestamps
    end
  end
end
