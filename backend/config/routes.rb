Rails.application.routes.draw do
  namespace :api do
    resources :health_check, only: [:index]
    resources :noop, only: [] do
      collection do
        get :ping
        get :lock
      end
    end
  end
end
