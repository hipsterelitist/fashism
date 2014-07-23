class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  before_filter :login_required, :except => [:new, :create, :index]
  
  def index
    render profile_path(params[:id])
  end
  
  def show
    #render :controller => 'profile', :action => 'view', :id => params[:id]
    redirect_to profile_url(:user_id => params[:id])
  end

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    birthday = Date.new(params[:user]['birthday(1i)'].to_i,params[:user]['birthday(2i)'].to_i,params[:user]['birthday(3i)'].to_i)
    @user.zip = params[:user][:zip].to_s.to_i
    #raise @user.zip
      
    @user.birthday = birthday
    
    
    #remove alpha/beta key logic after end of limited access
    if session[:beta_key] != nil
      @user.beta_key = session[:beta_key]
      key = Betakey.find_by_key(@user.beta_key)
      if key == nil
        flash[:warning] = "That key is invalid."
        render :action => 'new'
        return false
      end
      if key.uses > 0
        @user.save
          if @user.errors.empty?
            self.current_user = @user
            redirect_back_or_default('/')
            Notifier.deliver_welcome(@user)
            flash[:notice] = "Thanks for signing up!"
            key.uses = key.uses - 1
            key.save
          else
            render :action => 'new'
          end
      else
          flash[:warning] = "The registration cap for that key has already been reached."
          #must be render here or warning is lost
          render :action => 'new'
      end
    end
  end
  
  def edit
    @user = current_user
  end
  
  def update
    user = current_user
    if user.update_attributes(params[:user])
      flash[:notice] = "You've updated your settings."
    else
      flash[:warning] = "Ack! Something went wrong... are you scared?"
    end
    redirect_back_or_default('/')
  end
  
  ## for twitter auth
  def consumer
    OAuth::Consumer.new(ENV["TWITTER"], ENV["TWITTERKEY"], {:site => "http://twitter.com"})
  end
  

end
