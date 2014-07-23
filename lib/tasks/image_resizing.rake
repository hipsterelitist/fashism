require 'mini_magick'
require 'aws/s3'
include AWS::S3

namespace :resize_look_photos do
  desc "This size creates mini images from existing photos"
  task(:mini_images => :environment) do 
    AWS::S3::Base.establish_connection!(
      :access_key_id     => '1S668M04C1BREX80V4R2',
      :secret_access_key => 'SJJdenvtT8cb9xMrQMew0U5hINeAJG/B3ogxFmqg'
    )
    puts 'Creating new mini thumbnails...'
    for photo in Photo.find_by_sql(["SELECT * FROM photos WHERE parent_id IS null"])
      cake = Photo.find(:all, :conditions => { :parent_id => photo.id, :thumbnail => 'mini'})
      if !cake.nil?
        for cup in cake
          puts 'Destroying existing mini thumbnail with id/filename: ' + cup.id.to_s + ' ' + cup.filename.to_s 
          cup.destroy
        end
      end
      key = 'photos/' + photo.id.to_s + '/' + photo.filename
      object = S3Object.find key, 'fashism_dev'
      image_string = object.value.to_s
      scaled_image =  MiniMagick::Image.from_blob(image_string)
      scaled_image.scale('x120')
      new_filename = photo.filename.to_s[0..-5] + '_mini.jpg'
      new_photo = Photo.new
      new_photo.filename = new_filename
      new_photo.parent_id = photo.id
      new_photo.content_type = photo.content_type
      new_photo.thumbnail = "mini"
      new_key = 'photos/' + photo.id.to_s + '/' + new_filename
      S3Object.store(new_key, scaled_image.to_blob, 'fashism_dev', :access => :public_read)
      new_photo.size = S3Object.find(new_key, 'fashism_dev').content_length
      new_photo.width = scaled_image[:width]
      new_photo.height = '120'
      new_photo.save
    end
  end
  
  desc "This size creates feature images from existing photos"
  task(:feature_images => :environment) do
    AWS::S3::Base.establish_connection!(
      :access_key_id     => '1S668M04C1BREX80V4R2',
      :secret_access_key => 'SJJdenvtT8cb9xMrQMew0U5hINeAJG/B3ogxFmqg'
    )
    for photo in Photo.find_by_sql(["SELECT * FROM photos WHERE parent_id IS null"])
      key = 'photos/' + photo.id.to_s + '/' + photo.filename
      object = S3Object.find key, 'fashism_dev'
      image_string = object.value.to_s
      scaled_image =  MiniMagick::Image.from_blob(image_string)
      scaled_image.scale('400')
      new_filename =  photo.filename.to_s[0..-5] + '_compare.jpg'
      new_photo = Photo.new
      new_photo.filename = new_filename
      new_photo.parent_id = photo.id
      #thumbnails don't belong to a look
      #new_photo.look_id = photo.look_id
      new_photo.content_type = photo.content_type
      new_photo.thumbnail = "compare"
      new_key = 'photos/' + photo.id.to_s + '/' + new_filename
    
      #gangster, there is probably a better way to do this.
      S3Object.store(new_key, scaled_image.to_blob, 'fashism_dev', :access => :public_read)
    
      new_photo.size = S3Object.find(new_key, 'fashism_dev').content_length
      new_photo.height = scaled_image[:height]
      new_photo.width = '400'
      new_photo.save
    end
  end
  
  desc "This task resizes existing mini images"
  task(:resize_existing_mini => :environment) do
    AWS::S3::Base.establish_connection!(
      :access_key_id     => '1S668M04C1BREX80V4R2',
      :secret_access_key => 'SJJdenvtT8cb9xMrQMew0U5hINeAJG/B3ogxFmqg'
    )
    for photo in Photo.find_by_sql(["SELECT * FROM photos WHERE thumbnail='mini'"])
      puts "Resizing photo: " + photo.id.to_s + " " + photo.filename
      key = 'photos/' + photo.parent_id.to_s + '/' + photo.filename
      object = S3Object.find key, 'fashism_dev'
      image_string = object.value.to_s
      scaled_image =  MiniMagick::Image.from_blob(image_string)
      scaled_image.scale('x120')
      #new_filename = photo.filename.to_s[0..-5] + '_mini.jpg'
      #new_key = 'photos/' + photo.id.to_s + '/' + new_filename
      S3Object.store(key, scaled_image.to_blob, 'fashism_dev', :access => :public_read)
      photo.size = S3Object.find(key, 'fashism_dev').content_length
      photo.width = scaled_image[:width]
      photo.height = '120'
      photo.save
    end
  end
    
end