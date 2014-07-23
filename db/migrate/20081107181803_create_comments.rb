class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :user_id,            :int,     :null => false
      t.column :look_id,            :int,     :null => false
      t.column :body,               :string,  :null => false
      t.column :name,               :string
      t.timestamps
    end
      add_index :comments, :look_id
      add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
