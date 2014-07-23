class CommentsController < ApplicationController
  
  before_filter :login_required, :except => [:rank]
  
  def index
    if params[:user_id]
      @user = User.find_all_by_login(params[:user_id]).first
      @comments = @user.recent_comments
    else
      @comments = Comment.find(:all, :limit => 25, :order => "id DESC")
    end
  end
  
  def create
    
    if params[:look] == nil
      flash[:warning] = "We still haven't found what you're looking for..."
      redirect_to :controller => 'welcome'
      return false
    end
      
    if params[:comment] != nil
      @comment = Comment.new(params[:comment])
      @comment.user_id = current_user.id
      @comment.name = current_user.login
      @comment.look_id = params[:look][:id]
      #@comment.look.comment_count = (@comment.look.comment_count + 1)
      if @comment.save
        if @comment.look.user != nil
          @user = @comment.look.user
          if @user.id != current_user.id && @user.comment_notification
            Notifier.deliver_comment(@user, @comment, @comment.look)
          end
        end
        flash[:notice] = "We hope your feedback is appreciated."
      else
        flash[:warning] = "Oops, something went wrong with your comment..."
      end
    end
    respond_to do |format|
      format.html{
        redirect_to :controller => 'look', :action => 'view', :id => @comment.look_id
      }
      format.js{
        render :update do |page|
          #page.replace_html 'comment_column', :partial => 'look/comments', :locals => {:comments => @comment.look.comments.paginate}
          page.remove 'comment_form'
          page.replace_html 'flashes', :partial => 'shared/flashes'
        end
      }
    end
  end
  
  def rank
    @comment = Comment.find_by_id(params[:id])
    @comment_user = @comment.user
    
    if params[:helpful] == 'true'
      @comment.helpful = @comment.helpful + 1
      @comment_user.helpful = @comment_user.helpful + 1
      @position = "<span style='color:green;'>Helpful!</span>"
    elsif params[:snark] == 'true'
      @comment.snark = @comment.snark + 1
      @comment_user.snark = @comment_user.snark + 1
      @position = "<span style='color:red;'>Snarky!</span>"
    end
    
 
       if cookies[:rank] == nil
         rank_record= ""
       else
         rank_record = cookies[:rank]
       end
       
      if rank_record.rindex("z#{@comment.id}Z") == nil
         @comment.save
          @comment_user.save
         rank_record = rank_record + "z#{@comment.id}Z"
         cookies[:rank] = {:value => rank_record, :expires => 1.hour.from_now}
      else 
        @position = "Voting twice, eh?"
      end
  end

=begin  
  def ajax_create
    if params[:comment] != nil
      @comment = Comment.new(params[:comment])
      @comment.user_id = current_user.id
      @comment.name = current_user.login
      @comment.look_id = params[:voted_look][:id]
      if @comment.save
        if @comment.look.user != nil
          @user = @comment.look.user
          if @user.id != current_user.id && @user.comment_notification
            Notifier.deliver_comment(@user, @comment, @comment.look)
          end
          @photo = @comment.look.default_photo.public_filename(:thumb)
        end
        @response = "Your comment was successfully submitted."
      else
        @response = "Oops, something went wrong with your comment..."
      end
    end
  end
=end 
end
