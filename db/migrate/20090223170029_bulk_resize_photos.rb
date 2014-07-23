class BulkResizePhotos < ActiveRecord::Migration
  #CHANGE fashism_dev TO images.fashism.com FOR PRODUCTION BUCKET
  #OR ADD BUCKET/SERVER OPTION IN THE S3 BASE CONNECTION (PROBABLY NEED TO REMOVE REFERENCES TO dev)
  require 'mini_magick'
  require 'aws/s3'
  include AWS::S3
  
  def self.up
    AWS::S3::Base.establish_connection!(
      :access_key_id     => '1S668M04C1BREX80V4R2',
      :secret_access_key => 'SJJdenvtT8cb9xMrQMew0U5hINeAJG/B3ogxFmqg'
    )
    parent_photos = Photo.find_by_sql(["SELECT * FROM photos WHERE parent_id IS null"])
    for photo in parent_photos
      #FOR FEATRURE PHOTOS
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
      new_photo.width = '400'
      new_photo.save
=begin
      #for creating mini photos on production
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
      new_photo.height = '120'
      new_photo.save
=end
      
      end
  end

  def self.down
    AWS::S3::Base.establish_connection!(
      :access_key_id     => '1S668M04C1BREX80V4R2',
      :secret_access_key => 'SJJdenvtT8cb9xMrQMew0U5hINeAJG/B3ogxFmqg'
    )
    parent_photos = Photo.find_by_sql(["SELECT * FROM photos WHERE parent_id IS null"])
    for photo in parent_photos
      key = 'photos/' + photo.id.to_s + '/' + photo.filename.to_s[0..-5] + '_compare.jpg'
      key = S3Object.delete key, 'fashism_dev'
    end
  end
end
