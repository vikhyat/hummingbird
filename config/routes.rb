require 'sidekiq/web'

Hummingbird::Application.routes.draw do
  devise_for :users, controllers: { 
    registrations: "registrations",
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "users/sessions"
  }

  mount Forem::Engine => "/community"

  resources :beta_invites
  match "/beta_invites/resend_invite" => "beta_invites#resend_invite", as: :resend_beta_invite

  root :to => "home#index"

  # Dashboard
  match '/dashboard' => 'home#dashboard'
  resources :users do
    get "/watchlist" => 'users#watchlist',      as: :watchlist
    get "/reviews"   => 'users#reviews',        as: :reviews
    get "/forum_posts" => 'users#forum_posts',  as: :forum_posts
    
    post "/disconnect/facebook" => 'users#disconnect_facebook', 
      as: :disconnect_facebook
  end

  resources :watchlists

  # Search
  match '/search' => 'search#basic'
  
  # Imports
  match '/imports/myanimelist/new' => 'imports#myanimelist'
  match '/imports/review'          => 'imports#review', as: :review_import
  match '/imports/apply'           => 'imports#apply', as: :review_apply
  match '/imports/cancel'          => 'imports#cancel', as: :review_cancel

  resources :anime do
    resources :quotes do
      member { post :vote }
    end
    resources :reviews do
      member { post :vote }
    end
    resources :episodes do
      member { 
        post :watch 
        post :bulk_update
      }
    end
  end
  match '/reviews' => 'reviews#full_index'

  # Personalize Filters
  match '/anime/filter/:filter(/:page)' => 'anime#index', :as => :filtered_listing

  resources :genres
  resources :producers

  # Watchlist
  match '/watchlist/add/:anime_id' => 'watchlist#add_to_watchlist', 
    as: :add_to_watchlist
  match '/watchlist/remove/:anime_id' => 'watchlist#remove_from_watchlist', 
    as: :remove_from_watchlist
  match '/watchlist/rate/:anime_id/:rating' => 'watchlist#update_rating', 
    as: :update_rating

  # Admin Panel
  constraint = lambda do |request| 
    request.env["warden"].authenticate? and request.env['warden'].user.admin?
  end
  constraints constraint do
    match '/kotodama' => 'admin#index', as: :admin_panel
    mount Sidekiq::Web => '/kotodama/sidekiq'
    mount RailsAdmin::Engine => '/kotodama/rails_admin', as: 'rails_admin'
  end
end
