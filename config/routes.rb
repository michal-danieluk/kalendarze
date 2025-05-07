Rails.application.routes.draw do
  devise_for :users
  
  resources :calendars, only: [:index, :show]
  resources :orders, only: [:index, :new, :create, :show]
  
  # Anonymous order routes
  namespace :public do
    resources :orders, only: [:new, :create, :show]
  end
  
  namespace :admin do
    resources :orders, only: [:index, :show] do
      member do
        patch :confirm
        patch :reject
      end
      collection do
        get :export
        get :send_summary
        post :send_summary
        get :send_summary_by_email
        post :send_summary_by_email
        get :bulk_approve
      end
    end
    
    resources :users
    resources :calendars
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "calendars#index"
end
