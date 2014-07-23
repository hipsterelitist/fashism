class BrowseController < ApplicationController
  
  layout 'shell'

  def index
    if params[:perpage] != nil
      perpage = params[:perpage].to_i
    else
      perpage = 15
    end
    
    if params[:sort] == 'top'
      sort = "SCORE DESC"
    elsif params[:sort] == 'comments'
      sort = "COMMENT_COUNT DESC"
    else
      sort = "CREATED_AT DESC"
    end
    
      #this is without mislav-will_paginate... i'm still suspicious
    #@looks = Look.find(:all, :limit => perpage, :order => sort)
    
    @looks = Look.paginate :page => params[:page], :per_page => perpage, :order => sort
    respond_to do |format|
    format.html
    format.js{
      render :update do |page|
        page.replace_html :results, :partial => 'results'
        page << "ajaxifyPagination();"
      end
      }
    end
  end  
  
  def recent
    @page = params[:page].to_i
    if @page == nil || @page < 1
      @page = 1
    end
    
    @looks = Look.paginate :page => @page, :per_page => 5, :order => 'ID DESC'
    #raise @looks.class.to_s
    respond_to do |format|
      format.html
      format.js{
        @size = '100'
        render :update do |page|
          page.replace_html :look_browser, {:partial => 'browser', :locals => {:looks => @looks, :page => @page}}
        end
      }
    end
  end
  
end
