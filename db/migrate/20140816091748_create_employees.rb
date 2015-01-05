class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.belongs_to :shop
      t.string :name
      t.string :account
      t.string :phone
      t.string :password
      t.integer :authority
      t.string :email
      t.timestamps
    end
  end
end
