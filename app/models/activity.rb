class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :feeds, :dependent => :destroy
  belongs_to :item, :polymorphic => true
  
  def self.global_feed(size = 50)
    find(:all, :limit => size, :order => 'id DESC')
  end
end
