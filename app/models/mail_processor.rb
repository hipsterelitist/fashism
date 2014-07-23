require 'mms2r'
require 'tmail'

class MailProcessor < ActionMailer::Base

  def receive(mail)

    begin
        sender = mail.from.first
        mms = MMS2R::Media.new(mail)
        mail_look = Look.new
        if mms.subject != ''
          mail_look.title = mms.subject
        else
          mail_look.title = "Untitled Mobile Look"
        end
        media = mms.default_media
        cake = Photo.new(:uploaded_data => media)if 
          media.content_type.split('/').first == 'image'
        cake.look = mail_look
        cake.save!
        mail_look.sender = sender.to_s
        mail_look.default_photo_id = cake.id
        mail_look.record_sender
        mail_look.save!
    ensure 
      mms.purge
    end
  end

end
