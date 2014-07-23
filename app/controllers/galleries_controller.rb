class GalleriesController < ApplicationController
  
  before_filter :gallery_owner, :only => [ :edit, :update, :destroy ]
  before_filter :login_required, :only => [:new, :create]
  
  layout "compare"
  
  def index
    if params[:user_id].nil?
      @user = @current_user
    else
      @user = User.find_by_login(params[:user_id])
    end
    @galleries = Gallery.find_all_by_user_id(@user.id, :limit => 15, :order => 'id DESC')
  end
  
  def new
    @gallery = Gallery.new
  end
  
  def create
    @gallery = Gallery.new(params[:gallery])
    @gallery.user = @current_user
    
    if @gallery.save
       redirect_to :action => 'view', :id => @gallery.id
       flash[:notice] = "You've created a new gallery."
    else
       redirect_to :action => 'new'
       flash[:notice] = "Something went wrong."
    end
  end
      
    

  
  def show
    @user = User.find_by_login(params[:login])
    @looks = Look.find_all_by_gallery_id(params[:id])
  end   
  
  def view
    @gallery = Gallery.find_all_by_id(params[:id]).first
    
    if @gallery.gallery_items.empty? && @current_user.id != @gallery.user_id
      flash[:warning] = "That gallery is currently empty."
      redirect_to profile_path(:id => @gallery.user.login)
      return false
    elsif @gallery.gallery_items.empty? && @current_user.id == @gallery.user_id
      redirect_to :action => 'edit', :id => @gallery.id
    else
      @looks = @gallery.gallery_items
      if !params[:look_id].nil?
        @feature_look = @gallery.gallery_items.find_by_id(params[:look_id])
      else 
        @feature_look = @gallery.default_look
      end   
      @compare_look = @gallery.compare_look(@feature_look)
      #raise @feature_look.inspect
      
      @stat = GalleryStat.find_pair(@feature_look, @compare_look)
    end
    
  end
  
  def pass
    @gallery = Gallery.find_all_by_id(params[:id]).first
    @stashed = GalleryItem.find_by_id(params[:stashed])     
    @passed = GalleryItem.find_by_id(params[:passed])
    stat = GalleryStat.find_pair(@stashed, @passed)
    stat.pass(@passed)
=begin
    THIS SHOULD ALL BE MODEL CODE
    if (@gallery.nil? || @passed.nil? || @stashed.nil?) || (@passed.gallery_id != @stashed.gallery_id)
      redirect_to :back
      flash[:warning] = "What do you think you're doing?"
    else 
      stat = GalleryStat.find_pair(@stashed, @passed)
    end
=end
  end
  
  def selector
    @look = @current_user.looks.find_all_by_id(params[:id]).first
    @galleries = @current_user.galleries
  end
  
  def add
    @look = Look.find_all_by_id(params[:look]).first
    @gallery = Gallery.find_all_by_id(params[:gallery]).first

    if @look.user_id == @current_user.id && !@gallery.nil?
      @gallery_item = @gallery.add(@look)
    end
    
    if @gallery_item == false
      flash[:warning] = "That look cannot be added to that gallery."
      #redirect_to :controller => 'gallery', :action => 'edit', :id => @gallery.id
      return false
    end
  end
  
  def remove
    @look = Look.find_all_by_id(params[:look]).first
    @gallery = Gallery.find_all_by_id(params[:gallery]).first
    
    if @look.user_id == @current_user.id && !@gallery.nil?
      @removed_item_id = @gallery.remove(@look)
    end
  end
  
  def default
    @look = Look.find_all_by_id(params[:look]).first
    @gallery = Gallery.find_all_by_id(params[:gallery]).first
    @gallery.default_photo_id = @look.id
    @gallery.save
  end
  
  def edit
    @gallery = Gallery.find_by_id(params[:id])
  end
  
  def gallery_owner
    @gallery = Gallery.find_by_id(params[:id])

    if @gallery.nil? 
      flash[:warning] = "We still haven't found what you're looking for..."
      redirect_to :controller => "browse"
      return false
    elsif @current_user != @gallery.user
      redirect_to :action => 'show', :id => @gallery.id
      flash[:warning] = "You shouldn't meddle with things that don't belong to you..."
      return false
    else
       return true
    end
  end
  
end
