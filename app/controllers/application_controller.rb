# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '1a009b3bbf28ee49e818652ec5256c77'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  before_filter :alpha_access
  
  include AuthenticatedSystem
  layout 'application'
  
  def alpha_access
    if current_user != nil || session[:beta] == 'fashism-beta'
      return true
    else
      redirect_to :controller => 'alpha', :action => 'index'
    end
  end
  
  
end
