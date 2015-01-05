class CreateUserDiscounts < ActiveRecord::Migration
  def change
    create_table :user_discounts do |t|
      t.belongs_to :discount
      t.belongs_to :user
      t.timestamps
    end
  end
end
