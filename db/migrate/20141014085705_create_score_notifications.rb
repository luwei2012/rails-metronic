class CreateScoreNotifications < ActiveRecord::Migration
  def change
    create_table :score_notifications do |t|
      t.belongs_to :user
      t.belongs_to :score_record
      t.integer :status
      t.integer :type
      t.timestamps
    end
  end
end
