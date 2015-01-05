class AddIntegralToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :integral, :float
    add_column :users, :percent, :float
  end
end
