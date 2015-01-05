class AddSex < ActiveRecord::Migration
  def change
    add_column :users, :sex, :integer
  end
end
