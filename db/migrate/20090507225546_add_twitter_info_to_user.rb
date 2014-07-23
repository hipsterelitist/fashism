class AddTwitterInfoToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_login, :string
    add_column :users, :token, :string
    add_column :users, :secret, :string
    add_column :users, :last_twitter, :datetime
  end

  def self.down
    remove_column :users, :twitter_login
    remove_column :users, :token
    remove_column :users, :secret
    remove_column :users, :last_twitter
  end
end
