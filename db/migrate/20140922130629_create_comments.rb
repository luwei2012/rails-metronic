class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :user
      t.string :content
      t.integer :status
      t.integer :bonus_integral
      t.timestamps
    end
  end
end
