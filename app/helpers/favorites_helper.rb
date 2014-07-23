module FavoritesHelper
  
  def link_to_favorite(favorite)
    @user = favorite.user
    case favorite.item.class.to_s
    when "Look"
      return link_to(favorite.item.title, :controller => 'look', :action => 'view', :id => favorite.item.id)
    end
    
  end
end
