Elastic::Application.routes.draw do

  resources :segments

  match "/announce" => "sites#announce", :as => :announce
  match "/scrape" => "sites#scrape", :as => :scrape


  match '/contour' => 'contour/samples#index'

  match '/auth/failure' => 'contour/authentications#failure'
  match '/auth/:provider/callback' => 'contour/authentications#create'
  match '/auth/:provider' => 'contour/authentications#passthru'
  
  resources :authentications, :controller => 'contour/authentications'


  resources :downloaders do
    member do
      get :download_file
    end
  end

  devise_for :users, :controllers => {:registrations => 'contour/registrations', :sessions => 'contour/sessions', :passwords => 'contour/passwords'}, :path_names => { :sign_up => 'register', :sign_in => 'login' }

  resources :users do
    member do
      post :update_settings
    end
  end

  match "/about" => "sites#about", :as => :about
  match "/settings" => "users#settings", :as => :settings

  root :to => "downloaders#index"

end
