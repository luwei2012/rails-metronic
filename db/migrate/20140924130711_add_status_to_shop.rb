class AddStatusToShop < ActiveRecord::Migration
  def change
    add_column :shops, :cooperation, :boolean
    add_column :shops, :extra_priority_start_time, :datetime
  end
end
