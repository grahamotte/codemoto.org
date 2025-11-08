Rails.application.routes.draw do
  namespace :api do
    resources :noop, only: [] do
      collection do
        get :ping
        get :lock
        get :hc
      end
    end
  end
end
