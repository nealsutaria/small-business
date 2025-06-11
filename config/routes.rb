Rails.application.routes.draw do
  get 'webhooks/stripe'
  devise_for :users
  resources :categories
  devise_for :admins
  resources :products do
    resource :buy_now, only: [:show, :create], controller: :buy_now do
      get "success", on: :collection
    end
  end

  resource :cart, only: [:show, :destroy, :create] do
    get "checkout", on: :collection, to: "carts#checkout"
    post "stripe_session", on: :member, to: "carts#stripe_session"
    get "success", to: "carts#success"
  end

  post "/webhooks/stripe", to: "webhooks#stripe"
  get 'users/purchase_history', to: 'users#purchase_history', as: :purchase_history_users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resource :admin, only: [:show], controller: :admin

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "products#index"
end
