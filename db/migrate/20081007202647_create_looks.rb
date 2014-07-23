class CreateLooks < ActiveRecord::Migration
  def self.up
    create_table :looks do |t|
      
      
      t.column :user_id,            :int
      t.column :location,           :string
      t.column :zip,                :int
      t.column :store,              :string
      t.column :title,              :string, :null => false, :default => "Untitled Look"
      t.column :sender,             :string
      t.column :score,              :float, :null => false, :default => 0
      t.column :default_photo_id,   :int
      t.column :vote_count,         :int,   :null => false,   :default => 0


      t.timestamps
    end
    
    add_index :looks, :zip
    add_index :looks, :store
    add_index :looks, :score
    add_index :looks, :vote_count
  end

  def self.down
    drop_table :looks
  end
end
