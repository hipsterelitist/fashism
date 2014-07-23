class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string   "subject"
      t.text     "body"
      t.integer  "parent_id"
      t.integer  "sender_id"
      t.integer  "receiver_id"
      t.datetime "receiver_deleted_at"
      t.datetime "receiver_read_at"
      t.datetime "sender_deleted_at"
      t.datetime "sender_read_at"
      t.datetime "last_reply"
      t.boolean  "unread",        :default => true, :null => false
      t.timestamps
    end
        
    add_index 'messages', 'sender_id'
    add_index 'messages', 'receiver_id'
    
    add_column :users, :message_notification, :boolean, :default => true, :null => false
    add_column :users, :unread_count, :int, :default => 0, :null => false
    
  end

  def self.down
    drop_table :messages
    remove_column :users, :unread_count
    remove_column :users, :message_notification
  end
end
