class WelcomeController < ApplicationController
  
  layout 'with_photos'
  
  def index
    redirect_to :controller => 'look', :action => 'random'
  end
  
end
