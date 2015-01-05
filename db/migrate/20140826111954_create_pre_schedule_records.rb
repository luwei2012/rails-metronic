class CreatePreScheduleRecords < ActiveRecord::Migration
  def change
    create_table :pre_schedule_records do |t|
      t.belongs_to :shop
      t.integer :time_8
      t.integer :time_9
      t.integer :time_10
      t.integer :time_11
      t.integer :time_12
      t.integer :time_13
      t.integer :time_14
      t.integer :time_15
      t.integer :time_16
      t.integer :time_17
      t.integer :time_18
      t.datetime :start_time
      t.timestamps
    end
  end
end
