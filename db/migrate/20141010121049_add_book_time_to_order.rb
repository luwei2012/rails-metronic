class AddBookTimeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :book_time, :datetime
  end
end
