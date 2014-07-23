require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  has_one :user
  has_one :profile, :dependent => :destroy
  has_many :looks, :dependent => :destroy, :extend => TagCountsExtension
  has_many :connections
  has_many :galleries
  has_many :comments
  
  #NEEDS TO BE REWORKED, FOLLOWERS VERSUS CONTACTS ARE MIXED UP
  #THIS NEEDS TO BE MORE THOROUGHLY COMMENTED
  # Status codes: ACCEPTED = 0, REQUESTED = 1, PENDING = 2
  #EACH CONNECTION CONSISTS OF TWO ROWS, THE STATUS OF THE CONNECTION FOR EACH USER
  #IS DETERMINED BY THE STATUS CODE, WHICH SHOULD CHANGED GRACEFULLY BASED ON MODEL CODE
  #THE NATURE OF THESE CHANGES SHOULD BE DOCUMENTED HERE.
  NO_REQUESTED_FOLLOWERS = ["status = 0 or status = 2"]
  REQUESTED_FOLLOWERS = ["status = 1"]
  MUTUAL_FOLLOWERS = ["status = 0"]
  has_many :following_connections, :class_name => "Connection", :foreign_key => 'user_id', :conditions => NO_REQUESTED_FOLLOWERS
  has_many :contacts, :through => :connections, :conditions => NO_REQUESTED_FOLLOWERS, :order => 'users.id DESC'
  has_many :follower_connections, :class_name => "Connection", :foreign_key => 'contact_id', :conditions => NO_REQUESTED_FOLLOWERS
  has_many :followers, :through => :follower_connections, :source => :user
  has_many :requested_connections, :class_name => "Connection", :foreign_key => 'contact_id', :conditions => REQUESTED_FOLLOWERS
  has_many :requested_followers, :through => :requested_connections, :source => :user
  has_many :follower_requests, :through => :requested_connections, :source => :user
  has_many :mutual_connections, :class_name => "Connection", :foreign_key => 'contact_id', :conditions => MUTUAL_FOLLOWERS
  has_many :mutual_contacts, :through => :mutual_connections, :source => :user
  
  #feeds
  has_many :feeds
  #has_many :activities, :through => :feeds, :order => 'id desc', :conditions => ["activities.user_id = ?", self.id]
  has_many :activities, :order => 'id desc'
  
  
  attr_accessor :password

  validates_presence_of     :login, :email, :birthday
  validates_numericality_of :age,      :greater_than_or_equal_to => 13, :message => "- you must be 13 or older to use this site."
  validates_numericality_of :zip
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_validation_on_create :verify_age
  before_save :encrypt_password
  
  serialize :recently_viewed, Array

  after_create  :create_profile

  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :birthday, :vote_notification, :comment_notification

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def consumer
    OAuth::Consumer.new("960SZWQDtQmlxnANfs9B1w", "52nWnZVQJgJUd2O8xbxQaMzYUSRzax4t5iUOuUzM", {:site => "http://twitter.com"})
  end
  
  def photo
    ProfilePhoto.find_all_by_user_id(self.id).last
  end
  
  def profile_photo
    photo.nil? ? "default.png" : photo.public_filename
  end
  
  def thumbnail
    photo.nil? ? "default_thumb.png" : photo.public_filename(:thumb)
  end
  
  def icon
    photo.nil? ? "default_icon.png" : photo.public_filename(:icon)
  end
  
  def nano
    photo.nil? ? "default_nano.png" : photo.public_filename(:bound_icon)
  end
  
  def avatar
    photo.nil? ? "default_thumb.png" : photo.public_filename(:avatar)
  end
  
  def hottest_looks(limit = 5)
    self.looks.find(:all, :order => "score DESC", :limit => limit)
  end
  
  def recent_looks(limit = 5)
    self.looks.find(:all, :order => "id DESC", :limit => limit)
  end
  
  

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def connected?(user)
    Connection.exists?(self, user)
  end
  
  def following?(user)
    Connection.following?(self, user)
  end
  
  def recent_comments(limit = 25)
    self.comments.find(:all, :order => "id DESC", :limit => limit)
  end
  
  def recent_looks(limit = 25)
    self.looks.find(:all, :order => 'id DESC', :limit => limit)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def create_profile
      profile = Profile.new
      profile.user_id = self.id
      profile.age = self.age
      profile.name = self.login
      profile.login = self.login
      profile.zip = self.zip
      profile.save
      self.profile_id = profile.id
      self.save
    end
    

    def verify_age
      #self.zip = self.zip.to_i
      bday =  self.birthday
      if (bday - 13.years.ago).to_i < 0 
        self.age = (Date.today - birthday.to_date).to_i / 365
      else
        self.age = nil
      end
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    
end
