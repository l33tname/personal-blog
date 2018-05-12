require_relative "model.rb"

MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_BLOG_URI']}}, 'production')

SQL_DATE_FORMATER = "%Y-%m-%d %H:%M:%S"

for p in Post.all
    puts "INSERT INTO posts (text, created_at, updated_at, url)
 VALUES ('#{p.text.gsub("'", "\\\\'")}', '#{p.created_at.strftime(SQL_DATE_FORMATER)}', '#{p.updated_at.strftime(SQL_DATE_FORMATER)}', '#{p._id}');"
end

