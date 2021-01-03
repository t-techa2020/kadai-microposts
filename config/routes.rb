Rails.application.routes.draw do
  root to: 'toppages#index'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'signup', to: 'users#new'
  resources :users, only: [:index, :show, :new, :create] do
    # member の get :followings に対応して /users/:id/followings という URL が生成される
    member do
      get :followings
      get :followers
    end
  end
  
  get 'likes', to: 'user#likes'
  resources :users, only: [:index, :show, :new, :create] do
    member do
      get :likes
    end
  end
  
  resources :microposts, only: [:create, :destroy] 
  resources :relationships, only: [:create, :destroy]
  resources :favorites, only:[:create, :destroy]
end