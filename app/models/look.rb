class Look < ActiveRecord::Base
  include ActivityLogger
  
  acts_as_taggable
  has_many :votes
  has_many :comments
  
  belongs_to :user
  belongs_to :gallery
  has_many :photos, :dependent => :destroy
  
  validates_presence_of     :title
  validates_length_of       :title, :within => 4..50
  validates_length_of       :description, :within => 0..250, :allow_nil => true
  
  #before_update  :photo_ownership
  before_validation_on_create :truncate_title
  before_create :record_zip
  after_create :record_activity
  #after_create :ping_twitter
  
  attr_accessible :location, :zip, :default_photo_id, :store, :title, :description
  
  
  def self.recent(limit = 4, page = 1)
    Look.paginate :page => page, :per_page => limit, :order => 'id desc'
    #Look.find(:all,  :include => [:photos], :limit => limit, :order => 'id desc')
  end
  
  def recent_comments
    self.comments.find(:all, :order => "id DESC", :limit => 5)
  end
  
  def self.recent_cached
    Rails.cache.fetch('Look.recent_cached') {Look.recent}
  end
  
  def self.top(limit = 4)
    Look.find(:all, :include => [:photos, :user], :conditions => ['users.login IS NOT NULL'], :limit => limit, :order => 'score desc')
  end
  
  def self.top_cached
    Rails.cache.fetch('Look.top_cached') {Look.top}
  end
  
  
  def default_photo
    Photo.find_all_by_id(self.default_photo_id).first
  end
  
  def default_photo_url
    default_photo.nil? ? "default.png" : default_photo.public_filename
  end
  
  def record_sender
    if self.sender != nil
      user = User.find_by_email(self.sender)
      if user != nil
        self.user_id = user.id
      end
    end
  end
  
  def vote(vote)
    self.vote_count = self.vote_count + 1
    vote.score = (vote.score * 100)
    self.score = ((self.score.to_f * (self.vote_count-1))+vote.score)/(self.vote_count)
    
    
    if self.vote_count != 0
      case self.score
		    when 94..100
			  	 self.flavor = 	'Perfection.'
				  when 84..94
			  		self.flavor = 	'Pretty good.'
				  when 76..84
			  		self.flavor = 	'Meh.'
				  when 60..76
			  		self.flavor = 	'Not the best.'
				  when 50..60 
			  		self.flavor = 	'Eww.'
				  when 0..50  
			  		self.flavor = 	'OMG. My eyes.'
			  end 
      end
      
      if self.save!
        return true
      else
        retrun false
      end
  end
    
  protected 
  
  def record_activity
    if !self.user.nil?
      activity = Activity.create(:item => self)
      add_activities(:activity => activity, :user => self.user)
    end
  end
  
  def ping_twitter
    fashism_url = "http://fashism.com/look/view/" + self.id.to_s
    request_url = 'http://api.bit.ly/shorten?version=2.0.1&longUrl=' + fashism_url.to_s + '&login=fashism&apiKey=R_8256e0832cf77af1a8dcf159305f9abc'
    bitly_url = Net::HTTP.get(URI.parse(request_url))
    bitly_url = YAML::load(bitly_url)
    bitly_url = bitly_url["results"][fashism_url]["shortUrl"]
    twitter_message = "a new look was added by " + self.user.login + "... " + bitly_url
    twitter_reply = Net::HTTP.post_form(URI.parse('http://fashist_pig:cookies1013@www.twitter.com/statuses/update.json'), {'status'=> twitter_message}) 
    #twitter_reply = Net::HTTP.post_form(URI.parse('http://hipsterelitist:9121066@www.twitter.com/statuses/update.json'), {'status'=> twitter_message}) 
    if self.user.update_twitter == true
      twitter_message = bitly_url + " posted " + self.title
      twitter_reply = Net::HTTP.post_form(URI.parse('http://' + self.user.twitter_login + ':' + self.user.twitter_pass + '@www.twitter.com/statuses/update.json'), {'status'=> twitter_message})
    end
    
  end
  
  def truncate_title
    if self.title.length > 50
      self.title = self.title.slice(0..47) + "..."
    elsif self.title.length < 4
      self.title = "Untitled Mobile Look"
    end
  end
  
  def record_zip
    if self.user != nil 
      if self.user.zip != nil && self.zip == nil
        self.zip = self.user.zip
      end
    end
  end
  
  
end
