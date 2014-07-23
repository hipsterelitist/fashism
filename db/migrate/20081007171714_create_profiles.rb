class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column :user_id,                :int, :null => false
      t.column :login,                  :string
      t.column :name,                   :string
      t.column :phrase,                 :string
      t.column :bio,                    :text
      t.column :avatar,                 :string
      t.column :size,                   :int
      t.column :zip,                    :int
      t.column :age,                    :int

      t.timestamps
    end
    add_index :profiles, :zip
    add_index :profiles, :user_id
    add_index :profiles, :updated_at
    add_index :profiles, :age
    add_index :profiles, :login
  end

  def self.down
    drop_table :profiles
  end
end
