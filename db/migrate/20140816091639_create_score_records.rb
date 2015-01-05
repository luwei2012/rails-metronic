class CreateScoreRecords < ActiveRecord::Migration
  def change
    create_table :score_records do |t|
      t.belongs_to :order
      t.belongs_to :user
      t.float :wash_grade
      t.float :service_grade
      t.float :speed_grade
      t.float :env_grade
      t.float :average_grade
      t.string :comment
      t.timestamps
    end
  end
end
