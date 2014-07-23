class CreateGalleryStats < ActiveRecord::Migration
  def self.up
    create_table :gallery_stats do |t|
      t.integer :user_id, :null => false
      t.integer :gallery_id, :null => false
      t.integer :primary_item_id, :null => false
      t.integer :compare_item_id, :null => false
      t.integer :primary_passes, :default => 0
      t.integer :compare_passes, :default => 0
      t.integer :count, :default => 0
      t.timestamps
    end
    
    add_index :gallery_stats, [:primary_item_id, :compare_item_id]
  end

  def self.down
    drop_table :gallery_stats
  end
end
