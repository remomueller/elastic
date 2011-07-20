Elastic::Application.routes.draw do

  match "/announce" => "sites#announce", :as => :announce
  match "/scrape" => "sites#scrape", :as => :scrape

  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'

  resources :authentications

  resources :downloaders

  devise_for :users, :controllers => {:registrations => 'registrations'}, :path_names => { :sign_up => 'register', :sign_in => 'login' }

  resources :users do
    member do
      post :update_settings
    end
  end

  match "/about" => "sites#about", :as => :about
  match "/settings" => "users#settings", :as => :settings

  root :to => "sites#about"

end
