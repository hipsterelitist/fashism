class AddHelpfulnessToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :helpful, :int, :default => 0
    add_column :comments, :snark, :int, :default => 0
    
    add_column :users, :helpful, :int, :default => 0
    add_column :users, :snark, :int, :default => 0
  end

  def self.down
    remove_column :comments, :helpful
    remove_column :comments, :snark
  end
end
