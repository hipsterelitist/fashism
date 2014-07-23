class AddUserRecentlyViewed < ActiveRecord::Migration
  def self.up
    add_column :users, :recently_viewed, :string
    
  end

  def self.down
    remove_column :users, :recently_viewed
  end
end
