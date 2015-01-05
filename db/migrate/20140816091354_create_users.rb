class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :account
      t.string :phone
      t.string :password
      t.string :licence_plate
      t.string :email
      t.string :vehicle    #车的照片
      t.integer :integral
      t.decimal :balance
      t.timestamps
    end
  end
end
