class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.column :user_id,          :int
      t.column :look_id,          :int
      t.column :score,            :int

      t.timestamps
    end
    
    add_index :votes, :user_id
    add_index :votes, :look_id
    add_index :votes, :score
  end

  def self.down
    drop_table :votes
  end
end
