class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string,  :null => false
      t.column :email,                     :string,  :null => false
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40

      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :phone,                     :int
      t.column :birthday,                  :datetime
      t.column :zip,                       :int
      t.column :location,                  :string
      t.column :profile_id,                :int
      t.column :age,                       :int
      t.column :beta_key,                  :string
      
      t.timestamps
    end
    
    add_index :users, :login, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, :zip
    add_index :users, :profile_id
    add_index :users, :updated_at
    add_index :users, :age

    
  end

  def self.down
    drop_table "users"
  end
end
