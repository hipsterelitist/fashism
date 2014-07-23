class Profile < ActiveRecord::Base
  
  belongs_to :user

  validates_presence_of     :user_id, :name
  
  attr_accessible :name, :zip, :age, :bio, :phrase, :size
  

end
