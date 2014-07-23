module LookHelper
  
  def photo_for(look, size = :thumbnail)
      photo = look.photos.find_by_id(look.default_photo)
      look_image = photo.public_filename(size)
      image_tag(look_image, :alt => look.title).to_s
  end
  
  def percentage(look, precision = 0)
    if look.vote_count == 0
      return '??'
    else
      return number_to_percentage(look.score, :precision => precision).to_i   
    end
  end
  
  def styled_percentage(look, precision = 0)
    if look.vote_count == 0
      return '???'
    elsif look.score < 100
      string = number_to_percentage(look.score, :precision => precision).to_i.to_s + "<span style='letter-spacing:0px;font-size:25px;vertical-align:top;'>%</span>"
      return string 
    else 
      return look.score.to_i
    end
  end
  
end
