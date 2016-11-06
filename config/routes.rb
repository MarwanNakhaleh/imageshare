Rails.application.routes.draw do
  	get 'relationships/create'

  	get 'relationships/destroy'

  	resources :albums
  	resources :images
  	get '/dashboard' => 'pages#dashboard'
  	get '/tutorial' => 'pages#tutorial'

  	root 'pages#dashboard'

	get '/login' => 'sessions#new'
	post '/login' => 'sessions#create'
	get '/logout' => 'sessions#destroy'

	get '/signup' => 'users#new'
	post '/users' => 'users#create'
	get '/users/:id' => 'users#show'
	get '/user_directory' => 'users#index'

	resources :users do
		member do
			get :following, :followers
		end
	end
end
