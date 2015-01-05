class CreateLogRecords < ActiveRecord::Migration
  def change
    create_table :log_records do |t|
      t.string :title
      t.string :content
      t.string :type
      t.timestamps
    end
  end
end
