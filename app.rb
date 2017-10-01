require "sinatra"
require "redcarpet"
require "builder"
require "bcrypt"
require "sequel"

use Rack::Session::Pool

helpers do
  def admin? ; session["isLogdIn"] == true || DEBUG; end
  def protected! ; halt 401 unless admin? ; end
end

configure do
  set :erb, :layout => :'meta-layout/layout'
  set :erb, :locals => {:title => "Primärquelle", :tagline => "Seriösliche Nachrichten!"}

  Md = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
end

configure :development do
  DB = Sequel.sqlite
  
  set :show_exceptions, true
  DEBUG = true
end


configure :production do
  # mongodb://user:pass@host:port/dbname
  # MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_BLOG_URI']}}, 'production')
  DEBUG = false
end

# require after config!
require_relative "model.rb"

error 401 do
  "fuck no login"
end

get "/login/?" do
  erb :login
end

post '/login/?' do
  if params['username'] == ENV['USER'] && ENV['PASS'] == BCrypt::Engine.hash_secret(params['pass'], ENV['SALT'])
    session["isLogdIn"] = true
    redirect '/'
  else
    halt 401
  end
end

get('/logout/?'){ session["isLogdIn"] = false ; redirect '/' }


get "/" do
  erb :index, :locals => {:posts => Post.all_sorted, :onePost => false}
end

get "/impressum/?" do
  erb :impressum
end

get "/feed/?" do
  @posts = Post.all_sorted
  builder :rss
end

post "/add/:id" do |id|
  if id == "nil"
    post = Post.new(:text => params["text"])
  else
    post = Post.find(:id => id)
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
  erb :postAdd, :locals => {:post => Post.find(:id => id)}
end

get "/:id" do |id|
  erb :index, :locals => {:posts => Array(Post.find(:id => id)), :onePost => true}
end
