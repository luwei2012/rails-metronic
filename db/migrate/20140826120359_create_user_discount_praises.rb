class CreateUserDiscountPraises < ActiveRecord::Migration
  def change
    create_table :user_discount_praises do |t|
      t.belongs_to :discount
      t.belongs_to :user
      t.timestamps
    end
  end
end
