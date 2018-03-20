require_relative "model.rb"

MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_BLOG_URI']}}, 'production')

for p in Post.all
    puts "INSERT INTO posts (text, created_at, updated_at, url)
 VALUES ('#{p.text}', #{p.created_at.strftime('%Y%m%d %I:%M:%S %p')}, #{p.updated_at.strftime('%Y%m%d %I:%M:%S %p')}, '#{p._id}')"
end

