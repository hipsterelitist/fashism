class AddVoteToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :vote, :int
  end

  def self.down
    remove_column :comments, :vote
  end
end
