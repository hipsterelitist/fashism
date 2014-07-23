require 'ae_some_html'

class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User", :foreign_key => 'sender_id'
  belongs_to :receiver, :class_name => "User", :foreign_key => 'receiver_id'
  belongs_to :conversation
  
  validates_presence_of :body, :subject, :sender_id, :receiver_id
  validates_length_of :subject, :maximum => 40
  validates_length_of :body, :maximum => 5000
  
  before_create :assign_conversation, :strip_html
  after_create :set_unread_count, :set_last_reply
  
  def parent
    return @parent unless @parent.nil?
    return Message.find(parent_id) unless parent_id.nil?
  end
  
  def parent=(message)
    self.parent_id = message.id
    @parent = message
  end
  
  def set_unread_count
   self.receiver.unread_count = self.receiver.unread_count + 1
   self.receiver.save    
  end
  
  def other_user(user)
    if self.sender_id == user.id
      return self.receiver
    elsif self.receiver_id == user.id
      return self.sender
    else
      raise "I don't think you should be doing that..."
    end
  end
  
  def mark_as_read(time = Time.now)
    unless unread == false
      self.receiver_read_at = time
      self.unread = false
      receiver.unread_count = receiver.unread_count - 1
      receiver.save!
      save!
    end
  end
  
  def valid_reply?
    Set.new([sender, receiver]) == Set.new([parent.sender, parent.receiver])
  end
    
  def strip_html
    self.body = ae_some_html(self.body)
  end
  
  def trash(user)
    if user.id == self.sender_id
      self.sender_deleted_at = Time.now
    elsif user.id == self.receiver_id
      self.receiver_deleted_at = Time.now
      if self.unread == true
        receiver.unread_count = receiver.unread_count - 1
      end
    else 
      raise "I don't think anyone said you could do that..."
    end
    save!
  end
  
  def set_last_reply
    if parent != nil
      parent.last_reply = Time.now
      parent.save!
    end
  end
  
  def mark_sender_read
    self.sender_read_at = Time.now
  end
  
  def assign_conversation
    self.conversation = parent.nil? ? Conversation.create :
                                      parent.conversation
    mark_sender_read
  end
    
end
