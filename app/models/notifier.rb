class Notifier < ActionMailer::Base
    
  def new_password(user, new_password)
      setup_email(user)
      @subject    += 'You lost your password?'
      @body[:new_password]  = new_password
  end
  
  def welcome(user)
    setup_email(user)
    @subject += "Welcome to the party."
    @body[:user] = user
    
  end
  
  def message(message)
    setup_email(message.receiver)
    @subject += "You've got a new message"
    @body[:receiver] = message.receiver
    @body[:sender] = message.sender
    @body[:message] = message
  end
  
  def score(user, look)
    setup_email(user)
    @subject += "A verdict has been reached..."
    @body[:look] = look
  end 
  
  def score_anon(look)
    @recipients = "#{look.sender}"
    @from       = "Fashist HQ" "<info@fashism.com>"
    @subject    = "Fashism: A verdict has been reached..."
    @sent_on    = Time.now
    content_type "text/html"
    @body[:look] = look
  end
    
  
  def comment(user, comment, look)
    setup_email(user)
    @subject += "You've got a new comment from " + user.login + "!"
    @body[:look] = look
    @body[:comment] = comment
  end

  protected

  def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "Fashist HQ" "<info@fashism.com>"
      @subject     = "Fashism: "
      @sent_on     = Time.now
      @body[:user] = user
      content_type "text/html"
  end
  
end

