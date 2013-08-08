require "sinatra"
require_relative "model.rb"

get "/" do
	redirect "index.html"
end

get "/index.htm" do
	redirect "index.html"
end

get "/index/?" do
	redirect "index.html"
end

get "/blog/?" do
	erb :index
end

get "/impressum/?" do
	erb :impressum
end