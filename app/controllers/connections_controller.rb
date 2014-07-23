class ConnectionsController < ApplicationController
  before_filter :login_required
  
  def index
    @contacts = @current_user.contacts.paginate(:page => params[:page], :per_page => 25)
    @followers = @current_user.followers.paginate(:page => params[:page], :per_page => 25)
  end
  
  def followers
    
    @user = (params[:user_id].nil? ? @current_user : @user = User.find_all_by_login(params[:user_id]).first)
    
    if !@user.nil?
      @followers = @user.followers.paginate(:page => params[:page], :per_page => 25)
    else
      redirect_to :controller => :browse
      flash[:warning] = "We still haven't found what you're looking for..."
    end
    
  end
  
  def contacts
    @user = (params[:user_id].nil? ? @current_user : @user = User.find_all_by_login(params[:user_id]).first)
    
    if !@user.nil?
      @contacts = @user.contacts.paginate(:page => params[:page], :per_page => 25, :order => 'id ASC')
    else
      redirect_to :controller => :browse
      flash[:warning] = "We still haven't found what you're looking for..."
    end
  end
  
  def edit 
    if !params[:user].empty?
      @other_user = User.find_by_login(params[:user])
      @connection = Connection.conn(@current_user, @other_user)
      @contact = @connection.contact
    end
  end
  
  def unfollow
    if !params[:user].empty?
      user = User.find_by_login(params[:user])
      Connection.unfollow(@current_user, user)
    end
  end
  
  def follow
    if !params[:user].empty?
      @user = User.find_by_login(params[:user])
      Connection.follow(@current_user, @user)
    end
  end
  
  def create 
    @contact = User.find(prams[:login])
    
    respond_to do |format|
      if Connection.request(@current_user, @contact)
        flash[:message] = "You are now a follower of " + @contact.login.to_s
        format.html { redirect_to :contacts }
      else
        flash[:warning] = "Nice try slick, but that person doesn't want to be anywhere near you."
        format.html { redirect_to :contacts }
      end
    end
  end
  
  def update

    respond_to do |format|
      contact = @connection.contact
      login = contact.login
      case params[:commit]
      when "Accept"
        @connection.accept
        flash[:notice] = "You are now conntacted to #{login}."
      when "Decline"
        @connection.dissolve
        flash[:warning] = "You've declined to be #{login}'s contact."
      end
      format.html { redirect_to :back }
    end
  end
  
  
  def destroy
    if !params[:user].empty?
      user = User.find_by_login(params[:user])
      @connection = Connection.conn(@current_user, user)
      @connection.dissolve
    
      respond_to do |format|
        flash[:warning] = "You've dissolved your relationship with #{@connection.contact.login}"
        format.html{ redirect_to :back}
      end
    end
  end
end
