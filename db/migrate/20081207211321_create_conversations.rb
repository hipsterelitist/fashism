class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|

      t.timestamps
    end
    
    add_column :messages, :conversation_id, :int
    add_index :messages, :conversation_id
    
  end

  def self.down
    drop_table :conversations
    remove_index :messages, :conversation_id
    remove_column :messages, :conversation_id
  end
end
