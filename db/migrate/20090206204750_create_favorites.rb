class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.integer :user_id, :null => false
      t.integer :item_id, :null => false
      t.string :item_type, :null => false

      t.timestamps
    end
    
    add_index :favorites, :user_id
    add_index :favorites, :item_id
  end

  def self.down
    drop_table :favorites
  end
end
