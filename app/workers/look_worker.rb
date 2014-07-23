require_dependency 'look.rb'
require_dependency 'photo.rb'

class LookWorker < Workling::Base
  def process_look(options)
  #raise options[:look_info_hash].class.to_s
   # raise options[:look].class.to_s
    @look = options[:look]
    @file = options[:file]
    @file = File.join(RAILS_ROOT, @file)
    @photo = Photo.new :temp_path =>  File.open(@file, 'r'), :filename => @file, :content_type => 'image/jpg'
    
    service = LookService.new(@look, @photo)
    if service.save
      File.delete(@file)
    else 
      raise "Didn't work."
    end
  end
end