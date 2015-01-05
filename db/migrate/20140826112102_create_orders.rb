class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :discount
      t.belongs_to :user
      t.string :order_number
      t.integer :status
      t.decimal :price
      t.string :remark
      t.string :alipay_number
      t.timestamps
    end
  end
end
