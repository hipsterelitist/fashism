class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.boolean :public, :default => true
      t.integer :item_id, :null => false
      t.integer :user_id, :null => false
      t.string :item_type, :null => false
      t.string :message
      
      t.timestamps
    end
  
    add_index :activities, :item_id
    add_index :activities, :item_type

    create_table :feeds do |f|
      f.integer :user_id
      f.integer :activity_id
    end
  
      add_index :feeds, [:user_id, :activity_id]
  end

  def self.down
    drop_table :activities
    drop_table :feeds
  end
end
