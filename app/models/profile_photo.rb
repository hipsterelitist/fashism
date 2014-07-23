class ProfilePhoto < ActiveRecord::Base
      belongs_to :user
      has_attachment :content_type => :image, 
                     :storage => :file_system,
                     :max_size => 5.megabytes,
                     :resize_to => '800x600>',
                     :thumbnails => { :feature => '600x600>', :thumb => '50x50>', :avatar => '50>', :icon => '24>', :nano => '10>'}

      validates_as_attachment

      def uploaded_data=(file_data)
        super
        random_name = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand(250).to_s}--")
        self.filename = "#{random_name.to_s}#{File.extname(file_data.original_filename)}" if respond_to?(:filename)
      end

end
