class ProfilesController < ApplicationController
  
  before_filter :login_required, :except => [:show]

  def edit
    @profile = Profile.find(current_user.profile_id)
    if @profile == nil
      flash[:warning] = "Weird. We couldn't find your profile... Try again?"
      redirect_to :controller => 'browse'
    end
    @profile_photo = ProfilePhoto.new
    @profile_photo.user = @current_user
  end
  
  def update
    @profile = Profile.find_by_user_id(current_user.id)
    

      if @profile.update_attributes(params[:profile])
        flash[:notice] = "Your profile was updated!"
        redirect_to :controller => 'welcome', :action => 'index'
      else
        flash[:warning] = "Uh no! Something went wrong with updating your profile."
        redirect_to :action => 'edit'
      end
      
  end
  
  def profile_photo_form
    
  end
  
  def show
    if !params[:id].nil?
      @login = params[:id].to_s
    else
      @login = params[:user_id].to_s
    end
    if @login == '' || @login.nil?
      flash[:warning] = "You must enter a user name."
      redirect_to :controller => 'browse'
    else      
      @profile = Profile.find_by_login(@login)
      if @profile == nil
        flash[:warning] = "We couldn't find anyone with that login..."
        redirect_to :controller => 'browse'
      end
      @recent_looks = Look.find_all_by_user_id(@profile.id, :limit => '5', :order => 'id desc')
      @top_looks = Look.find_all_by_user_id(@profile.id, :limit => '5', :order => 'score desc')
    end
    
  end
end
