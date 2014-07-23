ActionController::Routing::Routes.draw do |map|
  map.resources :users, :has_many => [:look, :connections, :comments, :galleries], :has_one => [:password, :profile]

  map.resource :profile
  #map.resources :comment

  map.resource :session
  map.resource :looks
  map.resource :photos
  map.resource :favorites

  

  #map.resources :users, :has_one => [:password]
  
  
  #map.connect 'looks/:name', :controller => 'looks', :action => 'view'
  map.browse 'browse', :controller => 'browse', :action => 'index'
  map.user_looks 'users/:user_id/looks', :controller => 'look', :action => 'index'
  map.galleries   'users/:user_id/galleries', :controller => 'gallery', :action => 'index'
  map.user_contacts 'users/:user_id/contacts', :controller => 'connections', :action => 'contacts'
  map.user_followers 'users/:user_id/followers', :controller => 'connections', :action => 'followers'
  map.profile 'users/:user_id/profile', :controller => 'profiles', :action => 'show'
  map.followers 'followers', :controller => 'connections', :action => 'followers'
  map.contacts 'contacts', :controller => 'connections', :action => 'contacts'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activation '/activate', :controller => 'users', :action => 'activation'
  map.activate 'users/activate', :controller => 'users', :action => 'activate'
  map.settings '/settings', :controller => 'users', :action => 'edit'
  map.inbox '/inbox', :controller => 'messages', :action => 'index'
  map.feed 'users/:user_id/feed', :controller => 'activities', :action => 'index'
  map.favorites 'users/:user_id/favorites', :controller => 'favorites', :action => 'index'
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
