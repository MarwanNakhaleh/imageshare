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

Make sure to remove the following line from the Gemfile as well
```ruby
gem 'sqlite3'
```
We will be using Postgresql, so there is no need for SQLite.

### Creating databases
Edit your config/database.yml file to look like the following
```ruby
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
	Date of Birth: <%= f.date_select :dob, :start_year => Date.today.year - 100, :end_year => Date.today.year %><br />
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

  Username: <%= text_field_tag :username %>
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
### Adding a user avatar
This is an image sharing website, right? Wouldn't it only be right for a user to have a profile picture?  Let's make that now.
```bash
$ rails g migration AddAvatarToUsers
```
For this one, we're gonna manually write the migration for this. Navigate to /db/migrate/<timestamp>_add_avatar_to_users.rb, and then edit it to look like the following.
```ruby
class AddAvatarToUsers < ActiveRecord::Migration[5.0]
  def self.up
    change_table :users do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :users, :avatar
  end
end
```
Self.up tells Rails what to do when the attachment is created.  It adds a field of type attachment called avatar to the users table.  Conversly, self.down tells Rails what to do when the attachment is destroyed, it just drops the field from the table.  Now that you've changed the database schema, you need to migrate your database.
```bash
$ rake db:migrate
```
Next, we need to update the model to accept and validate an attachment, as the Paperclip gem requires.  Navigate back to /app/models/user.rb, and beneath 'has_secure_password', add the following lines.
```ruby
has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100#" }, :default_url => "/images/404.jpg"
validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
```
Now that the model has been updated, we need to update the controller and the view to allow for a user to upload an avatar.  So remember the users_controller.rb file we edited earlier?  We need to add another field to the user_params method. 

Navigate to /app/controllers/users_controller.rb and edit the user_params method such that it looks like this.
```ruby
def user_params
	params.require(:user).permit(
		:username,
		:first_name,
		:last_name,
		:email,
		:dob,
		:password,
		:password_confirmation,
		:avatar
		)
end
```
The avatar field needs to be allowed by the users controller within the permitted parameters. Finally, you need to add an avatar field to the view so a user can actually interact with that field. We're gonna go back into /app/views/users/new.html and plop in a file field.
```ruby
<%= form_for :user, url: '/users' do |f| %>
	First Name: <%= f.text_field :first_name %><br />
	Last Name: <%= f.text_field :last_name %><br />
	Username <%= f.text_field :username %><br />
	Avatar: <%= f.file_field :avatar, :accept => 'image/png,image/gif,image/jpeg'  %><br />
	Email: <%= f.text_field :email %><br />
	Date of Birth: <%= f.date_select :dob, :start_year => Date.today.year - 100, :end_year => Date.today.year %><br />
	Password: <%= f.password_field :password %><br />
	Password Confirmation: <%= f.password_field :password_confirmation %><br />
	<%= f.submit "Sign Up" %>
<% end %>
```
Now your user signup and authentication should be ready to go!
### Set up image uploads
It's back to the console to generate the model.
```bash
$ rails g model Image img:attachment title:string caption:string user_id:integer
$ rake db:migrate
```
Now that you have an Image table in the database, you can fix up the models such that you can access an image's user through image.user and a user's images through user.images!
Navigate to /app/models/user.rb and append the following line within the User class.
```ruby
has_many :images
```
Next, navigate to /app/models/image.rb and add the following lines within the Image class
```ruby
belongs_to :user
has_attached_file :img, :styles => { :medium => "300x300>", :thumb => "100x100#" }, :default_url => "/images/404.jpg"
validates_attachment_content_type :img, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
```
This creates the relationship between Image and User, and validates the image, as is necessary with the Paperclip gem.
After that, create a new file as /app/controllers/images_controller.rb and edit it to look like the following.
```ruby
class ImagesController < ApplicationController
	before_action :authorize

	def new
		@image = Image.new
	end

	def show
		@image = Image.find(params[:id])
	end

	def create
		@image = Image.new image_params
		@image.user_id = current_user.id
		if @image.save
			redirect_to root_path
		else
			redirect_to new_image_path
		end
	end

	def destroy
		@image = Image.find(params[:id])
		if image.destroy
			redirect_to root_path
		else
			redirect_to image_path(image.id)
		end
	end

	protected
	def image_params
		params.require(:image).permit(
			:title,
			:img,
			:caption,
			:user_id
			)
	end
end
```
Next, add the following line to /config/routes.rb.
```ruby
resources :images
```
What this does is generate the necessary routes you specified in the controller once you run the ```rake routes``` command.

To make use of this model and controller, we need views to create the items. Create a new file as /app/views/images/new.html.erb and edit the form to look like so.
```ruby
<h1>Upload an image</h1>

<%= form_for :image, url: "/images" do |f| %>
	Title <%= f.text_field :title %><br />
	Image: <%= f.file_field :img, :accept => 'image/png,image/gif,image/jpeg'  %><br />
	Caption: <%= f.text_field :caption %><br />
	<%= f.submit "Upload" %>
<% end %>
```
In the convention of ```resources :images```, the "/images" URL is routed to posting a new image and run the create method from the images controller. Next, we wanna be able to show some information about an image when we link to it. Create a new file /app/views/images/show.html.erb.
```ruby
<h1><%= @image.title %></h1>
<p>Uploaded by: <%= link_to @image.user.username, users_path(@image.user) %></p>
<p><%= image_tag(@image.img) %>
<p><%= @image.caption %></p>
```
This will pull in the @image instance variable we created in the show method in the images controller and gather its information to display.

Finally, we want to fix the dashboard so that it will show a user's images and display a button that will allow you to navigate to the image upload page.
Add the following lines to /app/views/pages/dashboard.html.erb
```ruby
<h2><%= current_user.first_name %>'s images</h2>
<%= button_to "Upload an image", new_image_path, method: :get %>
<% current_user.images.each do |image| %>
	<p><%= link_to image_tag(image.img.url(:thumb)), image_path(image) %></p>
<% end %>
```
And there you have it, you have a working image upload functionality!
### Provide flash srrors
Now as you might have noticed, we don't show any sort of error if something goes awry with any of the forms users fill out, we've just been redirecting so far.  We're gonna fix that so users can see error messages.  First we're gonna define a helper method in the application helper file.  Navigate to app/helpers/application_helper.rb and add the following code.
```ruby
def bootstrap_class_for flash_type
	case flash_type
		when :success
			"alert-success"
		when :error
			"alert-error"
		when :alert
			"alert-block"
		when :notice
			"alert-info"
		else
			flash_type.to_s
	end
end
```
What adding a method to application_helper.rb does is gives the entire application access to a particular method.  We will want flash notices to be available on many different pages of the website as necessary.

Create a new file in app/views/layouts called _flash.html.erb.  The underscore is necessary to denote that it is a partial view to be rendered in another page.  Add the following code to the file.
```ruby
<% flash.each do |type, message| %>
	<div class="alert <%= bootstrap_class_for(type) %> fade in">
		<button class="close" data-dismiss="alert">×</button>
    	<%= message %>
  	</div>
<% end %>
```
What this does is, this will go through any flash messages (that we will specify in the controllers) that have been set and display them in your view.  Now we need to display these flash messages.  Navigate to app/views/layouts/application.html.erb and add the following code right below the <body> tag.
```ruby
<%= render 'layouts/flash', flash: flash %>
```