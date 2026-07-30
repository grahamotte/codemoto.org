Rails.application.routes.draw do
  mount GoodJob::Engine => "/jobs"
  mount SolidErrors::Engine => "/errors"

  namespace :api do
    resources :noop, only: [] do
      collection do
        get :ping
        get :lock
        get :hc
        post :error
      end
    end
  end
end
