class CreateEmployeeRoles < ActiveRecord::Migration
  def change
    create_table :employee_roles do |t|
      t.belongs_to :role
      t.belongs_to :employee
      t.timestamps
    end
  end
end
