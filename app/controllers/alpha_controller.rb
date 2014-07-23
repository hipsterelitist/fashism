class AlphaController < ApplicationController
  
  skip_before_filter :alpha_access
  
  layout 'splash'
  
  def index
    if current_user != nil
      redirect_to :controller => 'welcome', :action => 'index'
    end
  end
  
  def authorize
    if @current_user == nil
      if params[:betakey] != nil
        key = Betakey.find_by_key(params[:betakey][:key])
      else 
        flash[:warning] = "Uh no! That key is invalid or expired."
        redirect_to :action => 'index'
      end
      
      if key != nil
        session[:beta] = "fashism-beta"
        session[:beta_key] = key.key.to_s
        key.views = key.views + 1
        key.save
        redirect_to :controller => 'welcome', :action => 'index'
      else 
        flash[:warning] = "Uh no! That key is invalid or expired."
        redirect_to :action => 'index'
      end
    else 
     return true
    end
  end
  
end
