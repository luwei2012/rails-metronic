class AddIntegralToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :integral, :float
  end
end
