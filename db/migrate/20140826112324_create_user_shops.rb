class CreateUserShops < ActiveRecord::Migration
  def change
    create_table :user_shops do |t|
      t.belongs_to :shop
      t.belongs_to :user
      t.timestamps
    end
  end
end
