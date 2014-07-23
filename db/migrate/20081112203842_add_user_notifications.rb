class AddUserNotifications < ActiveRecord::Migration
  def self.up
    add_column :users, :vote_notification, :int, :default => "25"
    add_column :users, :comment_notification, :boolean, :default => true
  end

  def self.down
    remove_column :user, :vote_notification
    remove_column :users, :comment_notification
  end
end
