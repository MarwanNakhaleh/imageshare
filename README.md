# How to Rails
### Create the app
```bash
$ rails new imageshare
$ cd imageshare
```
### Adding gems
Add the following to your Gemfile
```ruby
gem 'bootstrap-sass'
gem 'bcrypt', '~> 3.1.7'
gem 'devise'
gem 'paperclip'
gem 'pg'
```
### Creating databases
Edit your config/database.yml file to look like the following
```ruby
# SQLite version 3.x
#   gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem 'sqlite3'
#
default: &default
  adapter: postgresql
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: imageshare_dev

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: imageshare_test

production:
  <<: *default
  database: imageshare_prod
```
Then run the following commands
```bash
$ bundle install
$ rake db:create
```
### Creating the User model
We're not gonna bother with Devise for this, since it's too restrictive for our purposes
```bash
$ rails g model User first_name:string last_name:string email:string username:string password_digest:string dob:date
$ rake db:migrate
```
### Creating sessions
Navigate to /app/controllers/application_controller.rb and edit it to look like the following
```ruby
class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception

	helper_method :current_user

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def authorize
		redirect_to login_path unless current_user
	end
end
```
Then create a sessions controller
```bash
$ rails g controller sessions new create destroy
```
In your new sessions controller (located at /app/controllers/sessions_controller.rb), edit it to look like the following
```ruby
class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by_username(params[:username])
  	if user && user.authenticate(params[:password])
  		session[:user_id] = user.id
  		redirect_to root_path
  	else
  		redirect_to login_path
  	end
  end

  def destroy
  	session[:user_id] = nil
  	redirect_to login_path
  end
end
```
To log in a user, you have to create a user session. What the code for the create method does is find a user with the username, uses a helper method built into the User model through bcrypt's has_secure_password (which we'll get to later), then if the user exists and is successfully authenticated, the user will have a session, and the app will redirect to its root path, which we'll also get to later.

After that, create a users controller.
```bash
$ rails g controller users new create destroy
```
In your new users controller (located at /app/controllers/users_controller.rb), edit it to look like the following.
```ruby
class UsersController < ApplicationController
	def index
		@users = User.all
	end

	def new
	end

	def create
		user = User.new(user_params)
		if user.save
			session[:user_id] = user.id
			redirect_to root_path
		else
			redirect_to signup_path
		end
	end

	private
	def user_params
		params.require(:user).permit(
			:username,
			:first_name,
			:last_name,
			:email,
			:dob,
			:password,
			:password_confirmation
			)
	end
end
```
The index method indicates necessary code for when the /app/views/users/index.html.erb page is shown.  After that page is implemented, when the user navigates to localhost:3000/users, the user will be able to see a list of users, because they have access to a variable that displays all users.  For the new method, that essentially just takes from create for the purpose of this controller.  For the create method, a new user is created from the given permitted parameters in the user_params method.  If the user is saved, the user will automatically be logged in and redirected to the root path.  Otherwise they'll just be redirected to signup.  Finally, the user_params method is just a method that allows for only certain fields to be passed in through a form so hackers don't try to inject SQL or something.

Next, navigate to /app/models/user.rb and add the following line inside the User class
```ruby
has_secure_password
```
This comes from the bcrypt gem we added to our gemfile. This stores a password digest, an encrypted version of the password, in the database, so even if a hacker gets access to your database, they'd still have to decrypt the passwords to make any sense of it. This also adds the authenticate helper method to verify a user with a password.

Now we want to make a view such that users can actually sign up for this app.
Navigate to /app/views/users/new.html.erb and edit it to look like the following
```ruby
<%= form_for :user, url: '/users' do |f| %>
	First Name: <%= f.text_field :first_name %><br />
	Last Name: <%= f.text_field :last_name %><br />
	Username <%= f.text_field :username %><br />
	Email: <%= f.text_field :email %><br />
	Date of Birth: <%= f.date_select :date_of_birth, :start_year => Date.today.year - 100, :end_year => Date.today.year %><br />
	Password: <%= f.password_field :password %><br />
	Password Confirmation: <%= f.password_field :password_confirmation %><br />
	<%= f.submit "Sign Up" %>
<% end %>
```
This creates a form, allows for users to add in each of the required fields to create a user, and submits it.  Upon submission, it will call the create method from the users controller and go through that code to create the user.

Now that a user can sign up, we want a way for them to log in as well.  So we're gonna navigate to /app/views/sessions/new.html.erb and create a login view.
```ruby
<h1>Login</h1>

<%= form_tag '/login' do %>

  Email: <%= text_field_tag :email %>
  Password: <%= password_field_tag :password %>
  <%= submit_tag "Submit" %>

<% end %>
```
This routes the submission to the login path, which will be defined in config/routes.rb as sessions#create, which will call the create method in the sessions controller and create a user session.

Now, just so that users have somewhere to navigate to and so that we have an adequate root page, 
Finally, you need to add your new routes such that everything will point to the right thing.  Navigate to /config/routes.rb and edit it to look like the following.
```ruby
Rails.application.routes.draw do
  	get '/dashboard' => 'pages#dashboard'
  	get '/tutorial' => 'pages#tutorial'

  	root 'pages#dashboard'

	get '/login' => 'sessions#new'
	post '/login' => 'sessions#create'
	get '/logout' => 'sessions#destroy'

	get '/signup' => 'users#new'
	post '/users' => 'users#create'
end
```
This essentially says "when the user navigates to <web_app_url>/dashboard, it will link to the Rails route described by the command 'rake routes' as 'pages#dashboard'.  It essentially renames the routes to those pages to something more user-friendly." Speaking of user-friendly, open up /app/views/layouts/application.html.erb and add the following in the <body> tags.
```ruby
<% if current_user %>
	Signed in as <%= current_user.username %> | <%= link_to "Logout", logout_path %>
<% else %>
	<%= link_to 'Login', login_path %> | <%= link_to 'Signup', signup_path %>
<% end %>
```
Therefore, on every page, you will be able to login and logout. Stuff in application.html.erb will be visible and accessible everywhere in the web app. Now we need to one last thing. Go back to your terminal and type the following.
```bash
$ rails g controller pages dashboard tutorial
```
And now you have all the pages you need!  Just run 'rails s' and you'll have your user model and authentication working!
