class VoteController < ApplicationController
  
  def create
    vote = Vote.new()
    #raise params.inspect
    vote.look = Look.find_by_id(params[:look_id])
    vote.score = params[:score].to_i
    #raise vote.inspect
    if !current_user.nil? 
      vote.user = current_user
      if current_user.id == vote.look.user_id
        flash[:warning] = "You can't vote on your own look, that's rather like cheating."
        #redirect_back_or_default('/')
        return false
      end        
    end
    #raise vote.inspect
    
     if cookies[:vote_record] == nil
       #cookies[:vote_record] = { :value => "'", :expires => 1.hour.from_now }
       vote_record = ""
     else
       vote_record = cookies[:vote_record]
       #raise vote_record.to_s
     end
     
    if vote_record.rindex("z#{vote.look_id}Z") == nil
       vote_record = vote_record + "z#{vote.look_id}Z"
       cookies[:vote_record] = {:value => vote_record, :expires => 1.hour.from_now}
     else
       flash[:warning] = "You already voted on that look... We've reported you to the suede denim secret police."
       #redirect_to :back
       return false
     end
    
    if vote.save && (vote.look.vote(vote) == true)
      @look = vote.look
      #redirect_to :back
       flash[:notice] = "Your vote has been counted, move along citizen."
       if vote.look.user != nil
          user = vote.look.user
          if vote.look.vote_count == user.vote_notification
            Notifier.deliver_score(user, vote_look)
          end
        elsif vote.look.sender != nil && vote.look.vote_count == 25
            Notifier.deliver_score_anon(vote_look)
        end
        if !current_user.nil?
          if !session[:voting].nil?
            if session[:voting].length >= 5
              session[:voting].delete_at(0)
            end
          else
            session[:voting] = Array.new
          end
          session[:voting].push(vote.look_id)
        end
     else
       flash[:warning] = "Something was wrong with your vote, so we just tossed it out."
       redirect_to :controller => 'look', :action => 'view', :id => vote.look_id
       return false
     end
     
  end
  
end