class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.column :look_id,         :int
      t.column :parent_id,       :int
      t.column :size,            :int
      t.column :width,           :int
      t.column :height,          :int
      t.column :content_type,    :string
      t.column :filename,        :string
      t.column :thumbnail,       :string

      t.timestamps
    end
    
    add_index :photos, :parent_id
    add_index :photos, :look_id
  end

  def self.down
    drop_table :photos
  end
end
