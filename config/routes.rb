Elastic::Application.routes.draw do

  resources :segments

  match "/announce" => "sites#announce", :as => :announce
  match "/scrape" => "sites#scrape", :as => :scrape

  match '/auth/failure' => 'authentications#failure'
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/:provider' => 'authentications#passthru'

  resources :authentications

  resources :downloaders do
    member do
      get :download_file
    end
  end

  devise_for :users, :controllers => {:registrations => 'registrations'}, :path_names => { :sign_up => 'register', :sign_in => 'login' }

  resources :users do
    member do
      post :update_settings
    end
  end

  match "/about" => "sites#about", :as => :about
  match "/settings" => "users#settings", :as => :settings

  root :to => "downloaders#index"

end
