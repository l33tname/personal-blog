require "sinatra"
require "redcarpet"
require "builder"
require "bcrypt"
require "mysql2"
require "sequel"

use Rack::Session::Pool

class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

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
  # mysql2://user:pass@host/dbname
  DB = Sequel.connect(ENV['MYSQL_BLOG_URI'])
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
  if params['username'] == ENV['USER'] && BCrypt::Password.new(ENV['PASS']) == params['pass']
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
  post = nil
  if id.is_i?
    post = Post.find(:id => id)
  else
    post = Post.find(:url => id)
  end
  erb :index, :locals => {:posts => Array(post), :onePost => true}
end
