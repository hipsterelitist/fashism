class Photo < ActiveRecord::Base
  belongs_to :look
  belongs_to :user

    has_attachment :content_type => :image, 
                   :storage => :s3, 
                   :max_size => 5.megabytes,
                   :resize_to => '800x600>',
                   :thumbnails => { :thumb => '130>', :mini => 'x120', :tiny => '50>', :feature => '600x600>', :compare => '400' },
                   :processor => 'MiniMagick'

    validates_as_attachment
    
    def uploaded_data=(file_data)
      super
      random_name = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand(250).to_s}--")
      self.filename = "#{random_name.to_s}#{File.extname(file_data.original_filename)}" if respond_to?(:filename)
    end
    

end
