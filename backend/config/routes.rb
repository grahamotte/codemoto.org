Rails.application.routes.draw do
  namespace :api do
    resources :health_check, only: [:index]
  end
end
