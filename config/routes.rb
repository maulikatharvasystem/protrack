Protrack::Application.routes.draw do

  get "client_track_session/:id/index" => "client_track_session#index",as: :client_track_session

  get "client_track_session/:eng_id/show/:track_id" => "client_track_session#show",as: :client_track_session_show

  get "client_track_session/:eng_id/edit/:track_id" => "client_track_session#edit",as: :client_track_session_edit

  get 'manage_urls/'=> "users#manage_urls", as: :manage_urls
  put 'update_manage_urls/'=> "users#update_manage_urls", as: :update_manage_urls

  # patch "client_track_session/update"

  get "client_track_session/:id/destroy" => "client_track_session#destroy"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  root :to => 'users#login'

  #resources :device_users 
  #resources :models 
  namespace :api do
    match 'user_signin', :to => 'user#user_login', :via => "post"
    match 'user/login', :to => 'user#coockies_user_login', :via => "post"
    match 'user/logout', :to => 'user#coockies_user_logout', :via => "post"

    match 'user_signup', :to => 'user#user_registeration', :via => "post"
    match 'need_update', :to => 'user#need_update', :via => "post"
    match 'user/update_push_token', :to => 'user#coockies_update_push_token', :via => "post"

    match 'load_file', :to => 'user_file#load_file', :via => "post"
    match 'save_file', :to => 'user_file#save_file', :via => "post"
    #1.D
    match 'register_device', :to => 'device#device_registeration', :via => "post"
    #2.D
    match 'get_track', :to => 'track#get_track', :via => "post"
    match 'data', :to => 'track#coockies_get_track', :via => "get"
    match 'turns/:id/note', :to => 'track#coockies_update_turns', :via => "patch"
    #3.D
    match 'register_purchased_track', :to => 'track#register_purchased_track', :via => "post"
    #4.D
    match 'get_purchased_track_tn_detail', :to => 'track#get_purchased_track_tn_detail', :via => "post"
    #5.D
    match 'restore_purchased_track', :to => 'track#restore_purchased_track', :via => "post"
    #6.D
    match 'restore_purchased_track_tn_detail', :to => 'track#restore_purchased_track_tn_detail', :via => "post"

    match 'reports', :to => 'report#coockies_post_report', :via => "post"
    match 'reports/:id', :to => 'report#coockies_patch_report', :via => "patch"
    match 'reports/:id', :to => 'report#coockies_delete_report', :via => "delete"
    match 'track/:id', :to => 'track#add_note', :via => "patch"
  end
  resources :race_engineer_reports

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  #root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
end
