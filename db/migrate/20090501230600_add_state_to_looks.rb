class AddStateToLooks < ActiveRecord::Migration
  def self.up
    add_column :looks, :state, :int, :default => '0'
    @looks = Look.find(:all)
    for look in @looks
      look.state = 1
      look.save!
    end
  end

  def self.down
    remove_column :looks, :state
  end
end
