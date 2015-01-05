class CreateOrderNotifications < ActiveRecord::Migration
  def change
    create_table :order_notifications do |t|
      t.belongs_to :user
      t.belongs_to :order
      t.integer :status
      t.integer :type
      t.timestamps
    end
  end
end
