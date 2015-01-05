class AddDocumentToDiscountType < ActiveRecord::Migration
  def change
    add_column :discount_types, :icon, :integer
  end
end
