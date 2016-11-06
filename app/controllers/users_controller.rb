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

	def show
		@user = User.find(params[:id])
	end

	def following
	    @title = "Following"
	    @user  = User.find(params[:id])
	    @users = @user.following
	    render 'show_follow'
  	end

  	def followers
    	@title = "Followers"
    	@user  = User.find(params[:id])
    	@users = @user.followers
    	render 'show_follow'
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
			:password_confirmation,
			:avatar
			)
	end
end
