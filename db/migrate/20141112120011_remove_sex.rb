class RemoveSex < ActiveRecord::Migration
  def change
    remove_column :users, :sex
  end
end
