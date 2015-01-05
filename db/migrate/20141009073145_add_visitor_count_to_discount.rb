class AddVisitorCountToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :visitor_count, :integer
    add_column :discounts, :sale_price, :decimal
  end
end
