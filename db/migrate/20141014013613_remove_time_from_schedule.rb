class RemoveTimeFromSchedule < ActiveRecord::Migration
  def change
    remove_column :schedule_records, :time_8
    remove_column :schedule_records, :time_18
    remove_column :pre_schedule_records, :time_8
    remove_column :pre_schedule_records, :time_18
    remove_column :book_records, :time_8
    remove_column :book_records, :time_18
  end
end
