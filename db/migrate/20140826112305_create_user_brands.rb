class CreateUserBrands < ActiveRecord::Migration
  def change
    create_table :user_brands do |t|
      t.belongs_to :brand
      t.belongs_to :user
      t.timestamps
    end
  end
end
