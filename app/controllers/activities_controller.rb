class ActivitiesController < ApplicationController
  
  def index
    if params[:user_id].nil? && !@current_user.nil?
      @feed = []
      for feed_item in @current_user.feeds
        @feed.push(feed_item.activity)
      end
      #raise @feed.size.to_s
    else 
      user = User.find_all_by_login(params[:user_id]).first
      @feed = user.activities
    end
  end
  
end
