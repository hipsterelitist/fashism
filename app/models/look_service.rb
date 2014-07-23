class LookService
  
  attr_reader :look, :photo

  def initialize(look, photo)
    @look = look
    @photo = photo
    #raise @photo.inspect
  end

  
  def perform
    #raise self.photo.class.to_s
    self.save
  end
  
  def save
    #raise self.class.to_s
    #return false unless self.valid?
    #raise self.class.to_s
    #@look = YAMLload(self.look)
    #@photo = YAML.load(self.photo)
    begin
      Look.transaction do
        if @look.new_record?
          @photo.look = @look
          @photo.save!
          @look.default_photo_id = @photo.id
        elsif @look.photos.size >= 4
          return false
        else
          @photo.look = @look
          @photo.save!
        end
          @look.save!
        true
      end
    end
  end
=begin
  def valid?
      @look.valid? && @photo.valid?
  end
=end
  
end