require 'test_helper'
require 'performance_test_help'

class DelayedJobProcessingTest < ActionController::PerformanceTest
  fixtures :users
  # Replace this with your real tests.
  def test_homepage
    get '/'
  end
  
  def setup
    #user = :quentin
    open_session do |sess|
      sess.post '/login',  :login => 'quentin', :password => 'test'
    end
  end
  
  def test_submit_looks_for_processing
    x = 1990
    while x < 2000
      imagedata = fixture_file_upload('landing/hotel.jpg', 'image/jpg')
      
      post 'http://localhost:3000/look/create', {:look => { :title => x.to_s}, :photo_file => imagedata, :html => { :multipart => true }, :commit => 'Create' }
      x = x + 1
      if x = 2000
        break
      end
    end
  end
  
  
end
