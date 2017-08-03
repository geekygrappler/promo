Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'sessions' }
  resources :promotions
  # devise_for :users, controllers: { sessions: 'sessions' }

  # The public endpoints
  namespace :api do
    namespace :v1 do
      namespace :promocodes do
        post 'generate', to: 'public_promocodes#generate'
        post 'price', to: 'public_promocodes#price'
      end
      namespace :carts do
        post 'redeem', to: 'public_carts#redeem'
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
