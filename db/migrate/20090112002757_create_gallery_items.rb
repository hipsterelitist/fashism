class CreateGalleryItems < ActiveRecord::Migration
  def self.up
    create_table :gallery_items do |t|
      t.integer :look_id, :null => false
      t.integer :gallery_id, :null => false
      t.integer :default_photo_id
      t.integer :user_id
      t.integer :description
      t.integer :position
      t.integer :stashed, :default => 0
      t.integer :passed, :default => 0

      t.timestamps
    end
    add_index :gallery_items, :look_id
    add_index :gallery_items, :gallery_id
  end

  def self.down
    drop_table :gallery_items
  end
end
