class CreateBetakeys < ActiveRecord::Migration
  def self.up
    create_table :betakeys do |t|
      t.column :key, :string, :null => false
      t.column :uses, :int, :null => false, :default => '1'
      t.column :notes, :string
      t.column :total, :int, :default => '0'
      t.column :views, :int, :default => '0'

      t.timestamps
    end
    
    add_index :betakeys, :key, :unique => true
  end

  def self.down
    drop_table :betakeys
  end
end
