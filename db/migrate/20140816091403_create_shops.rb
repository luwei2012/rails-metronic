class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.belongs_to :brand
      t.belongs_to :chain
      t.string :name
      t.string :address
      t.float :longitude
      t.float :latitude
      t.string :telephone_number
      t.string :telephone_area_code
      t.integer :shop_photo
      t.text :description
      t.boolean :car_wash_bookable
      t.boolean :car_wash_online_pay_support
      t.float :extra_priority
      t.datetime :extra_priority_end_time
      t.timestamps
    end
  end
end
