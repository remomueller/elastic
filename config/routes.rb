Elastic::Application.routes.draw do

  resources :downloaders do
    member do
      get :download_file
    end
  end

  resources :segments

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users do
    member do
      post :update_settings
    end
  end

  get "/about" => "application#about", as: :about
  get "/settings" => "users#settings", as: :settings

  root to: "downloaders#index"

  # See how all your routes lay out with "rake routes"
end
