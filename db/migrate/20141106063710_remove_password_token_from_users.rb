class RemovePasswordTokenFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :password_reset_token
    remove_column :users, :password_reset_sent_at
  end
end
