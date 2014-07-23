class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :item, :polymorphic => true
  before_create :verify_unique
  
  def self.add(item_type, item_id, user)
    case item_type
    when 'Look'
      @item = Look.find_all_by_id(item_id).first
    when 'Comment'
      @item = Comment.find_all_by_id(item_id).first
    when 'Gallery'
      @item = Gallery.find_all_by_id(item_id).first
    end
    if !@item.nil?
      Favorite.create!(:item => @item, :user => user)
    end
  end
  
  protected
  
  def verify_unique
    if Favorite.find_by_user_id(self.user_id, 
      :conditions => ["item_id = ? AND item_type = ?", self.item_id, self.item_type],
      :order => 'id DESC').nil?
      return true
    else
      return false
    end
  end
    
end
