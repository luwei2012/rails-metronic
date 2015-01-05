class AddCarTypeToUser < ActiveRecord::Migration
  def change
    add_column :users, :car_type, :string
  end
end
