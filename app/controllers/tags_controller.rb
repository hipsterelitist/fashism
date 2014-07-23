class TagsController < ApplicationController
  
  before_filter :login_required, :except => [:view]
  
  
  def view
    if params[:perpage] != nil
      perpage = params[:perpage].to_i
    else
      perpage = 10
    end
    
    if params[:sort] == 'top'
      sort = "SCORE DESC"
    else
      sort = "CREATED_AT DESC"
    end
    
    options = Look.find_options_for_find_tagged_with(params[:id]).merge :page => params[:page], :per_page => perpage, :order => sort
    @looks = Look.paginate(options)
  end
  
  def add_tags
    if !params[:look_id].nil? && !params[:tag].nil?
      @look = current_user.looks.find(params[:look_id])
      @tags = params[:tag][:tag_list].to_s.gsub(', ',',').split(',')
      @look.tag_list.add(@tags)
      @look.save
    else 
      render :nothing => true
    end
  end
  
  def remove_tags
    if !params[:look_id].nil? && !params[:tags].nil?
      @look = current_user.looks.find(params[:look_id])
      @tags = params[:tags].to_s.split(',')
      @look.tag_list.remove(@tags)
      @look.save
    else 
      render :nothing =>  true
    end
  end
  
end
