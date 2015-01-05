class RemoveDicountTypeIdFromDiscount < ActiveRecord::Migration
  def change
    remove_column :discounts, :discount_type_id
  end
end
