class Connection < ActiveRecord::Base
  include ActivityLogger
  #extend PreferencesHelper
  
  belongs_to :user
  belongs_to :contact, :class_name => "User", :foreign_key => "contact_id"
  validates_presence_of :user_id, :contact_id
  
  after_create :record_activity
  
  #attr_accessible :user_id, :contact_id
  
  # Status codes.
  ACCEPTED  = 0
  REQUESTED = 1
  PENDING   = 2
  
  # Accept a connection request (instance method).
  # Each connection is really two rows, so delegate this method
  # to Connection.accept to wrap the whole thing in a transaction.
  def accept
    Connection.accept(user_id, contact_id)
  end
  
  def dissolve
    Connection.dissolve(user_id, contact_id)
  end
  
  class << self
  
    # Return true if the users are (possibly pending) connections.
    def exists?(user, contact)
      not conn(user, contact).nil?
    end
    
    alias exist? exists?
  
    # Make a pending connection request.
    def request(user, contact, send_mail = nil)
      if user == contact or Connection.exists?(user, contact)
        nil
      else
        transaction do
          create(:user => user, :contact => contact, :status => PENDING)
          create(:user => contact, :contact => user, :status => REQUESTED)
        end
        true
      end
    end
  
  
  
    # Accept a connection request.
    def accept(user, contact)
      transaction do
        accepted_at = Time.now
        accept_one_side(user, contact, accepted_at)
        accept_one_side(contact, user, accepted_at)
      end
    end
    
    def connect(user, contact, send_mail = nil)
      transaction do
        request(user, contact, send_mail)
        accept(user, contact)
      end
      conn(user, contact)
    end
    
    #alternative to connect, accurately creates relationships and accepts when mutual
    #might need modification if there needs to be approval for following
    
    def follow(user, contact)
      if user != contact
        if conn(contact, user).nil? && conn(user, contact).nil?
          transaction do
            create(:user => user, :contact => contact, :status => PENDING)
            create(:user => contact, :contact => user, :status => REQUESTED)
          end
        elsif exists?(contact, user) && !accepted?(contact, user)
          if exists?(user, contact) && !accepted?(user, contact)
            accept(contact, user)
          elsif !exists?(user, contact)
            transaction do
              create(:user => user, :contact => contact, :status => ACCEPTED)
              accept_one_side(contact, user, Time.now)
            end
          end
        end
      end
    end
        
  
    #alternative to dissolve which downgrades mutual connections or destroys requested relationships on unfollow.
    
    def unfollow(user, contact)
      destroy(conn(user, contact))
      other_connection = conn(contact, user)
        if !other_connection.nil?
          if other_connection.status == ACCEPTED
             other_connection.status = PENDING
             other_connection.save
          elsif other_connection.status == REQUESTED
             destroy(other_connection)
          end
        end
    end
    
    # Delete a connection or cancel a pending request.
    
    def dissolve(user, contact)
      transaction do
        destroy(conn(user, contact))
        destroy(conn(contact, user))
      end
    end
  
    # Return a connection based on the user and contact.
    def conn(user, contact)
      find_by_user_id_and_contact_id(user, contact)
    end
    
    def accepted?(user, contact)
      conn(user, contact).status == ACCEPTED
    end
    
    def connected?(user, contact)
      exist?(user, contact) and accepted?(user, contact)
    end
    
    def following?(user, contact)
      exists?(user, contact) and conn(user, contact).status != REQUESTED
    end
    
    def pending?(user, contact)
      exist?(user, contact) and conn(contact,user).status == PENDING 
    end
  end
  
  private
  
  def record_activity(conn)
    Activity.create!(:item => conn, :user => conn.user)
    add_activity(:activity => activity, :user => conn.user)
    add_activity(:activity => activity, :user => conn.contact)
  end
  
  class << self
    # Update the db with one side of an accepted connection request.
    def accept_one_side(user, contact, accepted_at)
      conn = conn(user, contact)
      conn.update_attributes!(:status => ACCEPTED,
                              :accepted_at => accepted_at)
    end
  end
end
