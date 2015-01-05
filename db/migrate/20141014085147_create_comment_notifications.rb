class CreateCommentNotifications < ActiveRecord::Migration
  def change
    create_table :comment_notifications do |t|
      t.belongs_to :user
      t.belongs_to :comment
      t.integer :status
      t.integer :type
      t.timestamps
    end
  end
end
