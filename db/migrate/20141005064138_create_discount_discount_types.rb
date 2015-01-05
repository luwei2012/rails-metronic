class CreateDiscountDiscountTypes < ActiveRecord::Migration
  def change
    create_table :discount_discount_types do |t|
      t.belongs_to :discount
      t.belongs_to :discount_type
      t.timestamps
    end
  end
end
