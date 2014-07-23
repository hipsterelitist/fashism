class CreateGalleries < ActiveRecord::Migration  
  def self.up
    create_table :galleries do |t|
      t.integer :user_id
      t.boolean :private, :default => false
      t.string :title
      t.string :description
      t.integer :size, :null => false, :default => 0
      t.integer :default_item_id

      t.timestamps
    end
    
    add_index :galleries, :user_id
    add_column :looks, :description, :string
  end

  def self.down
    drop_table :galleries 
    remove_column :looks, :description
  end
end
