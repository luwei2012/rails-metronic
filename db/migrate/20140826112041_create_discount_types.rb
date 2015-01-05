class CreateDiscountTypes < ActiveRecord::Migration
  def change
    create_table :discount_types do |t|
      t.string :name
      t.integer :value
      t.timestamps
    end
  end
end
