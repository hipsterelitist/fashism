class FavoritesController < ApplicationController
  before_filter :login_required, :except => [:index, :view]
  
  def index
    if !params[:user_id].nil?
      @user = User.find_by_login(params[:user_id])
      @favorites = Favorite.find_all_by_user_id(@user.id)
    end
  end
  
  def view
    if !params[:user_id].nil?
      user = params[:user_id].to_s
      @favorites = Favorite.find_all_by_user_id(user)
    end
  end
  
  def add
    item_id = params[:item_id]
    item_type = params[:item_type]
    user = @current_user
    
    if !item_id.nil? && !item_type.nil?
      Favorite.add(item_type, item_id, user)
    end
  end
  
end
