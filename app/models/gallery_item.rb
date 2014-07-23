class GalleryItem < ActiveRecord::Base
  belongs_to :gallery
  belongs_to :look
  belongs_to :user
  #has_many :statistics, :class => "GalleryStat", :foreign_key => 'primary_item_id'
  #has_many :compare_statistics, :class => "GalleryStat", :foreign_key => 'compare_item_id'
  #has_many :stats, :through => :gallery_stats, :conditions => ''
  
  def default_photo
    if self.default_photo_id.nil?
      return self.look.default_photo
    else
      return Photo.find_all_by_id(self.default_photo_id).first
    end
  end
    
  def default_photo=(photo)
    if photo.look_id != self.look_id
      return false
    else 
      self.default_photo_id = photo.id
      self.save
    end
  end
  
  def default_photo_url
   self.default_photo.public_filename
  end
  
end
