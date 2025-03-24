require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"

  # Cart routes
  resource :cart, only: [:show, :create, :destroy]
  
  post "cart/add_item", to: "carts#add_item"

  delete "cart/:id", to: "carts#destroy"   

  patch "cart/:id/decrease_quantity", to: "carts#decrease_quantity"
end
