class AddOrderTypeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :is_car_wash, :boolean
  end
end
