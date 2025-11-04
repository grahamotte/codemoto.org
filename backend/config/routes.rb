Rails.application.routes.draw do
  namespace :api do
    resources :restaurants, only: [ :index, :show ] do
      collection do
        post :sync_osm
      end
    end
    resources :reviews, only: [ :create, :update, :index ]
    resources :noop, only: [] do
      collection do
        post :ping
        post :lock
      end
    end

    resources :users, only: [] do
      collection do
        post :jwt
      end
    end

    resources :cookies, only: [] do
      collection do
        post :ingest
      end
    end

    resources :jobs, only: [] do
      collection do
        post :all
        post :view
        post :stats
        post :trigger
      end
    end

    resources :once, only: [] do
      collection do
        post :video
      end
    end

    resources :stars, only: [] do
      collection do
        post :list
        post :mark_starred
        post :mark_unstarred
      end
    end

    resources :files do
      collection do
        get :fonepaper
        get :wallpaper

        post :ids
        post :bulk_get
        post :mark_seen
        post :mark_unseen
        post :mark_starred
        post :mark_unstarred
        post :refresh_key

        get :proxy
        get "redirect/:id", to: "files#redirect"
      end
    end

    resources :objs do
      collection do
        post :refresh_key
      end
    end

    resources :streams, only: [] do
      collection do
        post :all
        post :add
        post :run
        post :mark_stream_enabled
        post :mark_stream_disabled
        post :remove
      end
    end

    resources :shows, only: [] do
      collection do
        post :all
        post :add
        post :run
        post :mark_enabled
        post :mark_disabled
        post :remove
      end
    end

    resources :feeds, only: [] do
      collection do
        post :all
        post :add
        post :run
        post :unseen_ids
        post :bulk_get_posts
        post :mark_post_seen
        post :mark_post_unseen
        post :mark_feed_enabled
        post :mark_feed_disabled
        post :mark_download_starred
        post :mark_download_unstarred
      end
    end

    resources :pods, only: [ :show ] do
      member do
        get "/cover", to: "pods#cover"
        get "/:track_id", to: "pods#track"
      end

      collection do
        post :all
        post :add
        post :mark_enabled
        post :mark_disabled
        post :remove
      end
    end
  end
end
