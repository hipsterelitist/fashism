class MessagesController < ApplicationController
  before_filter :login_required
  before_filter :authenticate_user, :only => [:view, :trash]
  
  def index
    @messages = Message.find_all_by_receiver_id(@current_user.id, :conditions => {:receiver_deleted_at => nil}, :order => "id DESC")
  end
  
  def view
    @message = Message.find(params[:id])
    @messages = Message.find_all_by_conversation_id(@message.conversation_id, :order => "id ASC")
    if @message.receiver_id == @current_user.id
      @message.mark_as_read
    end
  end
  
  def sent
    @messages = Message.find_all_by_sender_id(@current_user.id, :conditions => {:sender_deleted_at => nil}, :order => 'id DESC')
  end
  
  def new
    @message = Message.new
    if !params[:user].nil?
      @receiver = User.find_all_by_login(params[:user]).first
      if @receiver != nil
        @receiver = @receiver.login
      end
    end
  end
  
  def reply
    original = Message.find(params[:parent])
    receiver = original.other_user(@current_user)
    @reply = Message.new(:parent_id => original.id,
                                     :subject => original.subject,
                                     :sender => @current_user,
                                     :receiver => receiver
                                     )    
                                      
  end
  
  def user_list
    @user_name = params[:user_name].concat("%")
    @results = @current_user.contacts.find(:all, :conditions => ["login like ?", @user_name])
    render(:layout => false)
  end
  
  
  def create
    @message = Message.new(params[:message])
    #@receivers = params[:receiver].to_s.gsub(', ',',').split(',')
    #this would be for sending to multiple reciepents, make sure this doesn't bomb if one sender does not 
    #exist
    @receiver = User.find_all_by_login(params[:receiver])
    

    @message.sender = current_user
    if @receiver.first == nil
      flash[:warning] = "You're trying to send a message to a person that doesn't exist"
      redirect_to :controller => 'messages', :action => 'index'
      return false
    elsif  @receiver.first == @current_user
      flash[:warning] = "We know your style is eccentric, but talking to yourself is crazy."
      redirect_to :controller => 'messages', :action => 'index'
      return false
    else
      @message.receiver = @receiver.first
    end
    

    if reply?
      @message.parent = Message.find(params[:message][:parent_id])
      if !@message.valid_reply?
        flash[:warning] = "It seems as though you're trying to talk to someone you shouldn't..."
        redirect_to :back and return false
      end
    end


    respond_to do |format|
      if @message.save
        Notifier.deliver_message(@message)
        flash[:notice] = "Message sent!"
        format.html { redirect_to :action => 'view', :id => @message.id}
      else
        flash[:warning] = "Ack! Something went wrong with your message... perhaps you should try again?"
        format.html { redirect_to :back }
      end
    end
  end
  
  def trash
    @message = Message.find(params[:id])
    if @message.trash(@current_user)
      flash[:notice] = "Your message has been tossed."
    else
      # This should never happen...
      flash[:warning] = "That so isn't yours!"
    end
    redirect_to :action => 'index'
  end


  def reply?
      !params[:message][:parent_id].empty?
  end

  
  def authenticate_user
    @message = Message.find(params[:id])
    unless (@current_user == @message.sender or
            @current_user == @message.receiver)
      flash[:warning] = "That so doesn't belong to you!"
      redirect_to :controller => 'welcome'
    end
  end
  
  def authenticate_owner(message)
    unless (@current_user == @message.sender or 
            @current_user == @message.receiver )
      flash[:warning] = "That so doesn't belong to you!"
      redirect_to :controller => 'welcome'
    end
  end
  
end
