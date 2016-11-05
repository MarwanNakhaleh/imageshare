class AlbumsController < ApplicationController
	def index
		@albums = Album.all
	end

	def new
		@album = Album.new
	end

	def show
		@album = Album.find(params[:id])
	end

	def create
		@album = Album.new(album_params)
		@album.user_id = current_user.id
		if @album.save
			redirect_to root_path
		else
			redirect_to new_album_path
		end
	end

	def destroy
		@album = Album.find(params[:id])
		if @album.destroy
			redirect_to root_path
		else
			redirect_to album_path(@album)
		end
	end

	protected
	def album_params
		params.require(:album).permit(
			:title,
			:description,
			:user_id
			)
	end
end
