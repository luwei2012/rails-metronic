class AddColumnToTables < ActiveRecord::Migration
  def change
    remove_column :shops, :chain_id
    remove_column :brands, :value
    add_column :brands, :is_chain, :boolean
    add_column :brands, :brand_photo, :integer
  end
end
