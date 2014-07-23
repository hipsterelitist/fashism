class CreateProfilePhotos < ActiveRecord::Migration
  def self.up
    create_table :profile_photos do |t|
      t.column :user_id,         :int
      t.column :parent_id,       :int
      t.column :size,            :int
      t.column :width,           :int
      t.column :height,          :int
      t.column :content_type,    :string
      t.column :filename,        :string
      t.column :thumbnail,       :string
      #t.column :default,        :boolean
      
      # Default can be added in the case we want to keep multiple profile photos 
      # (such as if we want galleries outside of looks) but want leave one as the
      # default display/avatar. 
      
      t.timestamps
    end
    
    add_column :users, :profile_photo_id, :int
    
    add_index :profile_photos, :user_id
    add_index :profile_photos, :parent_id
  end

  def self.down
    remove_column :users, :profile_photo_id
    drop_table :profile_photos
  end
end
