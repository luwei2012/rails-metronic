class AddUserPhotoToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :vehicle
    add_column :users, :user_photo, :integer
    add_column :users, :car_photo, :integer
  end
end
