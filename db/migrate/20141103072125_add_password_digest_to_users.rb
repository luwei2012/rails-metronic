class AddPasswordDigestToUsers < ActiveRecord::Migration
  def change
    add_column :employees, :auth_token, :string
    add_column :employees, :password_digest, :string
    add_column :users, :password_digest, :string
  end
end
