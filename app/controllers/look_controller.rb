class LookController < ApplicationController

  layout "shell"

  before_filter :login_required, :except => [:new, :create, :view]
  
  def index
      if !params[:user_id].nil?
        login = params[:user_id].to_s
        @user = User.find_all_by_login(login).first
        if !@user.nil?
          @hottest = @user.hottest_looks
          @recent = @user.recent_looks
        else
          flash[:warning] = "We couldn't find that user"
          redirect_to :controller => 'browse'
        end
      else 
        @hottest = Look.top(10)
        @recent = Look.recent(10)
      end
  end
  
  def random
    offset = rand(Look.count :all)
    @look = Look.find :first, :offset => offset
    redirect_to :action => 'view', :id => @look.id
  end
  
  def next
    offset = params[:id].to_i
    @look = Look.find :first, :offset => offset
    if @look == nil
      @look = Look.find :first
    end
    redirect_to :action => 'view', :id => @look.id
  end
  
  def view
    
    
    @look = Look.find(params[:id], :include =>[:photos, :comments], :limit => 4)
    #@comments = @look.comments
    @comments = @look.comments.paginate(:page => params[:page], :per_page => 4, :order => 'ID DESC')
    respond_to do |format|
    format.html{
    if !params[:pid].nil?
        feature_photo = @look.photos.find_by_id(params[:pid])
    else
        feature_photo = @look.photos.find_by_id(@look.default_photo_id)
    end
    @default_photo = feature_photo.public_filename(:compare)

			if !session[:user_id].nil?
			  if session[:user_id] == @look.user_id
			    @owner = true
			  end
			end
    }
      format.js{
        render :update do |page|
          page.replace_html 'comment_column', :partial => 'comments', :locals => {:comments => @comments}
          page << "ajaxifyPagination();"
        end
      }
    end
  end
  
  def new
    @look = Look.new
  end
  
  def create
    @look = Look.new(params[:look])
    if !current_user.nil?
      @look.user_id = current_user.id
    end
    #@photo = Photo.new(:uploaded_data => params[:photo_file])
    direct = "tmp/landing"
    random_name = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand(250).to_s}--")
    random_name = random_name + File.extname(params[:photo_file].original_filename)
    path = File.join(direct, random_name)
    if params[:photo_file].size < 5.megabytes && params[:look][:title].length > 3
      File.open(path, 'wb') do |f|
        #f.binmode
        f.write params[:photo_file].read
        @file = f.path
      end
      look_info_hash = { :look => @look, :file => @file}
      LookWorker.async_process_look(look_info_hash)
    else 
      flash[:warning] = "Something isn't quite right..."
      redirect_to :back
      return false
    end


    

    


    redirect_to :controller => 'welcome'
    flash[:notice] = "Your look should show up in just a moment!"
  end
  
  def edit
    @look = Look.find(params[:id])
    if @look.user_id != current_user.id
      redirect_to :action => 'view', :id => @look.id
      flash[:warning] = "That ain't your look, hun."
    end
  end
  
  def update
    @look = Look.find(params[:id])
      if params[:photo_file].nil?
        if @look.update_attributes(params[:look])
          flash[:notice] = "You've updated your profile!"
          redirect_to :action => 'view', :id => @look.id
        else
          flash[:warning] = "Oh no! Something about that wasn't right."
          render :action => 'edit', :id => params[:id]
        end
      else
        @look.update_attributes(params[:look])
        @photo = Photo.new(:uploaded_data => params[:photo_file])
        @service = LookService.new(@look, @photo)
        if @service.save
          flash[:notice] = "You've added a new photo!"
          redirect_to :action => 'view', :id => @look.id
        elsif @look.photos.size >= 4
          flash[:warning] = "I'm sure it is lovely, but do you really need more than 4 shots?"
          render :action => 'edit', :id => params[:id]
        else
          flash[:warning] = "Oh no! Something about that wasn't right."
          render :action => 'edit', :id => params[:id]          
        end
      end
  end
  
  def manage
    @looks = Look.paginate :page => params[:page], :per_page => 15, :order => 'ID ASC', :conditions => ['user_id  =? ', current_user.id]
    if @looks == nil
      flash[:notice] = "You have no looks, you really should upload one before you go trying to change things..."
      redirect_to :action => 'new'
    end
    respond_to do |format|
    format.html
    format.js{
      render :update do |page|
        page.replace_html :results, :partial => 'results'
        page << "ajaxifyPagination();"
      end
      }
    end
  end
  
  def destroy
    @look = Look.find_by_id(params[:id])
    
    if @look.user_id == current_user.id
      flash[:warning] = "We hope you meant that... there is no undo..."
      @look.destroy
    else
      flash[:warning] = "That look doesn't seem to belong to you... don't be so naughty, you might get punished."
    end
    redirect_to :action => "manage"
  end
  
  def destroy_look
    @look = Look.find_by_id(params[:id])
    
    if @look.user_id != current_user.id
      flash[:warning] = "That look doesn't seem to belong to you... don't be so naughty, you might get punished."
      redirect_to :action => 'browse'
    end
      
  end
    
#all of the photo related stuff should be moved to the photo controller....
  
  def edit_photo
    photo = Photo.find(params[:pid])
    
    if photo.look.user_id != current_user.id
      flash[:warning] = "Were you trying to do something naughty? You don't own that photo..."
      redirect_to :controller => 'browse'
      return false
    end
    
  end
  
  def make_default
    photo = Photo.find(params[:pid])
    
    if photo.look.user_id != current_user.id
      flash[:warning] = "Were you trying to do something naughty? You don't own that photo..."
      redirect_to :controller => 'browse'
      return false
    end
    
    if photo.id == photo.look.default_photo_id
      flash[:warning] = "Oh snap, you can't do that... that's already your default photo!"
      redirect_to :controller => 'browse'
      return false
    else
      photo.look.default_photo_id = photo.id
      if photo.look.save
        flash[:notice] = "You've changed the default photo for your look... looks good."
      end
      redirect_to :action => 'edit', :id => photo.look.id
    end
    
  end
  
  def destroy_photo
    
    photo = Photo.find(params[:pid])
    
    if photo.look.user_id != current_user.id
      flash[:warning] = "Were you trying to do something naughty? You don't own that photo..."
      redirect_to :controller => 'browse'
      return false
    end
    
    if photo.id == photo.look.default_photo_id
      flash[:warning] = "Oh snap, you can't do that... that's your look's default photo!"
      redirect_to :action => 'edit', :id => photo.look.id
      return false
    else 
      photo.destroy
      flash[:notice] = "You've deleted your photo... probably wasn't that great anyway..."
      redirect_to :action => 'edit', :id => photo.look.id
    end    
  end
  
  def comments
    @comments = Look.find_by_id(params[:look_id]).comments.paginate(:all, :page => [:page], :per_page => 5)
    respond_to do |format|
      format.html{
        redirect_to :back
      }
      format.js{
        render :update do |page|
          page.replace_html 'comment_column', :partial => 'comments', :locals => {:comments => @comments}
        end
      }
      format.xml{ render :xml => @comments }
    end
  end
  
  def display_image
    respond_to do |format|
      format.html{
        redirect_to :back
      }
      format.js{
        render :update do |page|
          photo = params[:photo]
          photo = Photo.find_by_id(photo)
          page.replace 'display_photo', :partial => 'display_photo', :locals => {:photo => photo }
        end
      }
    end
  end
end
