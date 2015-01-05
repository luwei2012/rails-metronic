class RemoveAccountFromEmployee < ActiveRecord::Migration
  def change
    remove_column :employees, :account
  end
end
