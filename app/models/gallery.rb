class Gallery < ActiveRecord::Base
  
  attr_accessible :title, :description
  belongs_to :user
  has_many :gallery_items, :dependent => :destroy
  
  validates_length_of :title, :maximum => 200, :allow_nil => true
  validates_length_of :description, :maximum => 1000, :allow_nil => true
  validates_presence_of :user_id
  
  before_create :handle_nil_descriptors
  before_destroy :reset_looks
  
  def add(look)
    if self.gallery_items.find_all_by_look_id(look.id).first.nil?
      item = GalleryItem.new
      item.look = look
      item.user = self.user
      item.position = (self.gallery_items.size.to_i)
      item.gallery = self
      if item.save
        return item
      end
    else
      return false
    end
  end
  
  def remove(look)
    item = self.gallery_items.find_all_by_look_id(look.id).first
    if !item.nil?
      item.destroy
      return item.id
    else
      return false
    end
  end
      
      
  
  def default_look
    if self.default_item_id.nil?
      return self.gallery_items.first
    else
      return Gallery_item.find_by_id(self.default_item_id)
    end
  end
    
  def default_look=(look)
    if look.nil?
      self.default_item_id = self.gallery_items.first.id 
      #self.default_item_id = nil
    else
      item = Gallery_item.new
      item.look = look
      item.gallery = self
      item.save
      self.gallery_item.default_item_id = item.id
    end
  end
  
  def default_photo_url
    if default_look.nil?
      return "default.png"
    #elsif !default_look.default_photo.id.nil?
    #  return Photo.find_all_by_id(default_look.default_photo.id).first.public_filename
    else
      return default_look.default_photo.public_filename
    end
  end
  
  def compare_look(look = nil)
    if look.nil?
      @compare_look = default_look
    else
      #raise look.inspect
      origin = self.gallery_items.find_by_id(look.id)
      @compare_look = (origin.nil? ?  self.gallery_items[1] : self.gallery_items.find_by_position(origin.position+1))
      @compare_look = (@compare_look.nil? ? self.gallery_items[0] : @compare_look)
    end
  end
  
  
  def thumb_url
    default_look.nil? ? "default_thumb.png" : default_look.default_photo.public_filename(:thumb)
  end
  
  def icon_url
    default_look.nil? ? "default_icon.png" : default_look.default_photo.public_filename(:icon)
  end
  
  def bounded_icon_url
    default_look.nil? ? "default_icon.png" : default_look.default_photo.public_filename(:bounded_icon)
  end
  
  protected 
  
  def handle_nil_descriptors
    self.description = "" if description.nil?
    self.title = self.user.login.to_s + "'s untitled gallery." if title.nil?
  end
end
