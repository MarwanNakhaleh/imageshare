Rails.application.routes.draw do
  resources :images
  	get '/dashboard' => 'pages#dashboard'
  	get '/tutorial' => 'pages#tutorial'

  	root 'pages#dashboard'

	get '/login' => 'sessions#new'
	post '/login' => 'sessions#create'
	get '/logout' => 'sessions#destroy'

	get '/signup' => 'users#new'
	post '/users' => 'users#create'
	get '/user_directory' => 'users#index'
end
