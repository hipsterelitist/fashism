require 'ae_some_html'

class Comment < ActiveRecord::Base
  include ActivityLogger
  
  
  belongs_to :user
  belongs_to :look
  
  
  validates_presence_of     :user_id, :body, :look_id
  validates_length_of       :body, :within => 4..500
  
  before_create :strip_html
  after_create :comment_count
  after_create :record_activity
  
  def strip_html
    self.body = ae_some_html(self.body)
  end
  
  private
  
  def record_activity
    activity = Activity.create!(:item => self, :user => user)
    add_activities(:activity => activity, :user => user)
    unless self.look.user_id.nil? or user == self.look.user
      add_activities(:activity => activity, :user => self.look.user,
                     :include_person => true)
    end
  end
  
  def comment_count
    self.look.comment_count = self.look.comment_count + 1
    self.look.save
  end
  
end
