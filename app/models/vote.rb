class Vote < ActiveRecord::Base
  
  belongs_to :look
  belongs_to :user
  
  
end
