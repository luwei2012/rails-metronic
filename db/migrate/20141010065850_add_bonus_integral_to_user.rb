class AddBonusIntegralToUser < ActiveRecord::Migration
  def change
    add_column :users, :bonus_integral, :integer
  end
end
