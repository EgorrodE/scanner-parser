Rails.application.routes.draw do
  root 'home#index'

  post 'upload_data', to: 'home#upload_data'

  resources :hosts


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
