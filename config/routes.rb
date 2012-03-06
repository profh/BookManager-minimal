BookManager::Application.routes.draw do

  # Nifty authentication routes
  match 'user/edit' => 'users#edit', :as => :edit_user
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login
  resources :sessions
  resources :users
  
  # Generated model routes
  resources :authors
  resources :categories
  resources :books
  
  # Additional routes
  match 'proposed' => 'books#proposed', :as => :proposed_books
  match 'contracted' => 'books#contracted', :as => :contracted_books
  
  # Set the root url
  root :to => 'books#index'

end
