class PhotoController < ApplicationController
  before_filter :login_required
  
  def create_profile_photo
      @profile_photo = ProfilePhoto.new(:uploaded_data => params[:photo_file])
      @profile_photo.user = @current_user
      if @profile_photo.save
        #if @current_user.profile != nil 
        #  @current_user.profile_photo.default = false
        #end
        @current_user.profile_photo_id = @profile_photo.id
        flash[:message] = "You've got a new profile photo!"
      else 
        flash[:warning] = "Something went awry."
      end
      redirect_to :controller => 'profile', :action => 'edit'
    end
    
end
