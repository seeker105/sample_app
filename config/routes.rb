Rails.application.routes.draw do

  get 'directmessages/:sender_id/new/:receiver_id', to: 'directmessages#new', as: :message_new
  post 'directmessages/:sender_id/create/:receiver_id', to: 'directmessages#create', as: :message_create
  get 'directmessages/:sender_id/show/:receiver_id', to: 'directmessages#show', as: :message_show
  get 'directmessages/:user_id/sent', to: 'directmessages#sent', as: :messages_sent
  get 'directmessages/:user_id/received', to: 'directmessages#received', as: :messages_received

  root "static_pages#home"
  get "help", to: "static_pages#help"
  get "about", to: "static_pages#about"
  get "contact", to: "static_pages#contact"
  get "signup", to: "users#new"
  get "login", to: 'sessions#new'
  post "login", to: 'sessions#create'
  delete "logout", to: 'sessions#destroy'
  get "request_github_access", to: 'sessions#request_github_access'
  get "/auth/github/callback", to: 'sessions#exchange_token'

  post "user/listuser/new/:list_id/:user_id", to: 'listusers#add', as: :listuser_new
  delete "user/list/:listuser_id", to: 'listusers#delete', as: :listuser_delete
  # get "users/:user_id/lists", to: 'lists#index', as: :lists
  get "users/:user_id/lists/new", to: 'lists#new', as: :list_new
  post "users/:user_id/lists/create", to: 'lists#create', as: :list_create
  delete "users/:user_id/lists/destroy/:list_id", to: 'lists#destroy', as: :list_destroy
  get "users/:user_id/lists/:id", to: 'lists#show', as: :list_show

  get "git_main", to: 'git_pages#show'
  get "organizations", to: 'organizations#index'

  resources :users do
    resources :lists, only: :index
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
end
