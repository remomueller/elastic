Elastic::Application.routes.draw do

  resources :downloaders do
    member do
      get :download_file
    end
  end

  resources :segments

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users do
    member do
      post :update_settings
    end
  end

  match "/about" => "sites#about", as: :about
  match "/settings" => "users#settings", as: :settings

  root to: "downloaders#index"

end
