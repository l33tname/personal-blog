require 'active_model/serializers'
require "mongo_mapper"

class Post
	include MongoMapper::Document

	key :text, String, :require => true
	timestamps!
end
