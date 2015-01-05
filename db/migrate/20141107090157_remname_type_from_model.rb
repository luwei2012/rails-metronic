class RemnameTypeFromModel < ActiveRecord::Migration
  def change
    rename_column :comment_notifications ,:type,:comment_notification_type
    rename_column :log_records ,:type,:log_record_type
    rename_column :order_notifications ,:type,:order_notification_type
    rename_column :score_notifications ,:type,:score_notification_type
  end
end
