class RemoveBonusFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :bonus_integral
  end
end
