class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.where(:email => params[:email]).last
    puts "\n\n\nUser: #{user}\n"
    puts "Authenticated?: #{user.authenticate(params[:password])}\n\n\n"
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
