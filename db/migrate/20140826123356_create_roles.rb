class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.integer :authority
      t.string :duty
      t.timestamps
    end
  end
end
