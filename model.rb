require "mongo_mapper"

class Post
	include MongoMapper::Document

	key :link, String, :require => true
	key :text, String, :require => true
	timestamps!
end