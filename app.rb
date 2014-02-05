require "sinatra"
require "redcarpet"
require 'builder'
require_relative "model.rb"

use Rack::Session::Pool

helpers do
  def admin? ; session["isLogdIn"] == true || DEBUG; end
  def protected! ; halt 401 unless admin? ; end
end

configure do
  set :erb, :layout => :'meta-layout/layout'
  Md = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
end

configure :development do
  AppConfig = YAML.load_file(File.expand_path("config.yaml", File.dirname(__FILE__)))["development"]
  
  MongoMapper.database = 'blog'
  
  set :show_exceptions, true
  DEBUG = true
end

configure :production do
  AppConfig = YAML.load_file(File.expand_path("config.yaml", File.dirname(__FILE__)))["production"]
  
  MongoMapper.connection = Mongo::Connection.new(AppConfig["Mongo"]["Host"], AppConfig["Mongo"]["Port"].to_i)
  MongoMapper.database = 'blog'
  MongoMapper.database.authenticate(AppConfig["Mongo"]["User"], AppConfig["Mongo"]["Pass"])
  DEBUG = false
end

error 401 do
  "fuck no login"
end

get "/login/?" do
  erb :login
end

post '/login/?' do
  if params['username'] == AppConfig["User"] && params['pass'] == AppConfig["Pass"]
    session["isLogdIn"] = true
    redirect '/'
  else
    halt 401
  end
end

get('/logout/?'){ session["isLogdIn"] = false ; redirect '/' }


get "/" do
  erb :index, :locals => {:posts => Post.sort(:created_at.desc).all(), :onePost => false}
end

get "/impressum/?" do
  erb :impressum
end

get "/feed/?" do
  @posts = Post.sort(:created_at.desc).all()
  builder :rss
end

post "/add/:id" do |id|
  if id == "nil"
    post = Post.new(:text => params["text"])
  else
    post = Post.find(id)
    puts post.text
    if post == nil
      halt 404
    end
    post.text = params["text"]
  end

  if !post.save
    halt 500
  end
  redirect "/"
end

get "/edit/:id" do |id|
  erb :postAdd, :locals => {:post => Post.find(id)}
end

get "/:id" do |id|
  erb :index, :locals => {:posts => Post.where(:id => id).sort(:created_at.desc), :onePost => true}
end