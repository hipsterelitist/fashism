class CreateConnections < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.integer :user_id, :null => false
      t.integer :contact_id, :null => false
      t.integer :status, :default => 0
      t.timestamp :accepted_at

      t.timestamps
    end
    add_index :connections, [:user_id, :contact_id]
    
  end

  def self.down
    drop_table :connections
  end
end
