module ActivitiesHelper
  def feed_message(activity)
      @user = activity.user
    case activity.item.class.to_s
    when "Look"
      look = activity.item
      url = link_to('look', :controller => 'look', :action => 'view', :id => look.id)
      message = user_link(@user)
      message = message + " added a new " + url + "."
      return message
    when "Comment"
      comment = activity.item
      look_owner = comment.look.user
      url = link_to('look', :controller => 'look', :action => 'view', :id => comment.look.id)
      message = user_link(@user)
      message = message + " commented on " + look_owner.login.to_s + "'s " + url
      return message
    end
  end
  
  def feed_link
  end
  
  def user_link(user)
    if @current_user == user
      return link_to('You', profile_path(:user_id => user.login))
    else
      return link_to(user.login.to_s,  profile_path(:user_id => user.login))
    end
  end
end
