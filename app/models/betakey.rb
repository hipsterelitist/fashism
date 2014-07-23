class Betakey < ActiveRecord::Base
  has_many :users

  
  validates_presence_of         :key, :uses
  validates_uniqueness_of       :key
  
  before_create :set_total
  
  protected
  
  def set_total
    self.total = self.uses
  end
  
end
