class AddFlavorToLooks < ActiveRecord::Migration
  def self.up
    add_column :looks, :flavor, :string, :default => ' '
  end

  def self.down
    remove_column :looks, :flavor
  end
end
