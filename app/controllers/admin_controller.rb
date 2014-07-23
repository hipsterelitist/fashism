class AdminController < ApplicationController
  before_filter :login_required, :admin_access
  
  layout 'admin'
  
  def admin_access
    if current_user.login != "admin"
      flash[:warning] = "You must be an admin to access the admin site. Go away."
      redirect_to :controller => 'welcome', :action => 'index'
    end
  end
  
  
  def index
    redirect_to :controller => 'welcome', :action => 'index'
  end
  
  def action
  end
  
  def new_key
  end
  
  def beta_keys
    @beta_keys = Betakey.find(:all)
  end
  
  def create_key
    @key = Betakey.new(params[:betakey])
    @key.save!
    if @key.errors.empty?
      redirect_to :action => "beta_keys"
    else
      flash[:warning] = "Something went wrong with making your key..."
      redirect_to :action => "new_key"
    end 
  end
  
  def edit_key
    @betakey = Betakey.find_by_id(params[:id])
  end
  
  def update_key
    key_id = params[:betakey][:id].to_s
    key = Betakey.find_by_id(key_id)
    if key.update_attributes(params[:betakey])
      flash[:notice] = "Key updated"
    else
      flash[:warning] = "Something went wrong with updating the key."
    end
    
    redirect_to :action => "edit_key", :id => key.id
  end
  
  def users
    @users = User.find(:all)
  end
  
  def flagged
    @flagged = Flag.find(:all)
  end
  
  def manage_looks
    @looks = Look.find(:all)
  end
  
  def destroy_look
    if params[:destroy_id] != nil 
      look = Look.find(params[:destroy_id])
      flash[:warning] = "You removed " + look.id.to_s + " and all of its dependents. (except votes... photos are toast.)"
      look.destroy
    end
      redirect_to :action => 'manage_looks'  
  end
  
  def destroy_user
    if params[:destroy_id] != nil
      user = User.find(params[:destroy_id])
      flash[:warning] = "You removed " + user.login + " and all of its dependents. (except votes... looks, photos, etc should be toast.)"
      user.destroy
    end
      redirect_to :action => 'users'
  end
      
  
end
