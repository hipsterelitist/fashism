class GalleryStat < ActiveRecord::Base
  belongs_to :gallery
  belongs_to :user
  belongs_to :gallery
  belongs_to :primary_item, :class_name => "GalleryItem", :foreign_key => "primary_item_id", :dependent => :destroy
  belongs_to :compare_item, :class_name => "GalleryItem", :foreign_key => "compare_item_id", :dependent => :destroy
  before_create :validate_pair
  
  def destroy_related
    stat = GalleryStat.find_by_sql(["SELECT * FROM gallerystats WHERE primary_item_id IS ?", self.id])
    stat = stat + GalleryStat.find_by_sqll(["SELECT * FROM gallerystats WHERE compare_item_id IS ?", self.id])
    stat.each{|x| x.destroy}
  end
  
  def validate_pair
    GalleryStat.validate_pair(self.primary_item, self.compare_item)
    #self.primary_item.gallery_id == self.compare_item.gallery_id && !(Gallery.find_all_by_id(self.gallery_id).nil?)
  end

  def pass(passed_item)
    if passed_item.id == self.primary_item_id
      self.primary_passes = self.primary_passes + 1
    elsif passed_item.id == self.compare_item_id
      self.compare_passes = self.compare_passes + 1
    else 
      raise 'Unacceptable ID for this pair'
    end
      #raised = "Huh: passed item id: " + passed_item.id.to_s + " primary_item_id: " + self.primary_item_id.to_s + " compare_item_id: " + self.compare_item_id.to_s
      #raise raised
      self.count = self.count + 1
      self.save!
  end
  
  class << self
  
    def find_pair(item_one, item_two)
      #raise item_one.inspect
      pair = order(item_one, item_two)
      @stat = GalleryStat.find_by_primary_item_id(pair.first, :conditions => {:compare_item_id => pair.last})
      if @stat.nil?
        @stat = GalleryStat.create(item_one, item_two)
      end
      return @stat
    end
    
    def create(item_one, item_two)
      pair = order(item_one, item_two)
      stat = GalleryStat.new({:gallery_id => item_one.gallery_id, :primary_item_id => pair.first, :compare_item_id => pair.last, :user_id => item_one.gallery.user_id })
      stat.save!
    end
  
    def validate_pair(item_one, item_two)
      item_one.gallery_id == item_two.gallery_id && !(Gallery.find_all_by_id(item_one.gallery_id).nil?)
    end
  
    def order(item_one, item_two)
      pair = [item_one.id, item_two.id]
      pair.sort!
    end
  end
  
end
