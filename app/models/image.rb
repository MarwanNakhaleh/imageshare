class Image < ApplicationRecord
	belongs_to :user

	has_attached_file :img, :styles => { :medium => "300x300>", :thumb => "100x100#" }, :default_url => "/images/404.jpg"
	validates_attachment_content_type :img, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
