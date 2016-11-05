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
