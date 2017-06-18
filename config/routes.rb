Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # TODO this promotions resource doesn't belong in the public API
      resources :promotions, only: [:create]
      post 'generate', to: 'promocodes#generate'
      post 'price', to: 'promocodes#price'

    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
