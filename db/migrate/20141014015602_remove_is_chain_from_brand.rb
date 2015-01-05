class RemoveIsChainFromBrand < ActiveRecord::Migration
  def change
    remove_column :brands, :is_chain
  end
end
