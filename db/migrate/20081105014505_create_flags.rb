class CreateFlags < ActiveRecord::Migration
  def self.up
    create_table :flags do |t|
      t.column :user_id, :int
      t.column :type, :string
      t.column :item_id, :int
      t.column :resolved, :boolean

      t.timestamps
    end
    add_index :flags, :item_id
    add_index :flags, :resolved
    add_index :flags, :type
  end

  def self.down
    drop_table :flags
  end
end
