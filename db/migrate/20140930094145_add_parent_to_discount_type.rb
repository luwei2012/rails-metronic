class AddParentToDiscountType < ActiveRecord::Migration
  def change
    add_column :discount_types, :parent, :integer
  end
end
