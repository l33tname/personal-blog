require "sinatra"
require_relative "model.rb"

use Rack::Session::Pool

helpers do
  def admin? ; session["isLogdIn"] == true || DEBUG; end
  def protected! ; halt 401 unless admin? ; end
end

configure :development do
  MongoMapper.database = 'blog'
  set :show_exceptions, true
  DEBUG = false
end

configure :production do
  AppConfig = YAML.load_file(File.expand_path("../config.yaml", File.dirname(__FILE__)))["production"]
  set :views, Proc.new { File.join(root, "../views") }
  set :public_folder, Proc.new { File.join(root, "../public") }

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
    erb :error401
  end
end

get('/logout/?'){ session["isLogdIn"] = false ; redirect '/' }

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

post "/add/?" do
	redirect "/blog"
end