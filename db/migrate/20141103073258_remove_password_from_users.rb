class RemovePasswordFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :password
    remove_column :employees, :password
  end
end
