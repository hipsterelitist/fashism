module CommentHelper
  def comment_vote_image(comment)
    if comment.vote.nil?
      return ''
    elsif comment.vote.score == 1
      return image_tag('../images/ui/btn_like_it.gif')
    elsif comment.vote.score == 0
      return image_tag('../images/layout/btn_hate_it.gif')
    else
      return false
    end
  end
  
end
