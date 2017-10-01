Sequel::Model.plugin :timestamps

# create_table! Drop the table if exists, and then create the table
# create_table? Create the table only if it doesn't exists.
DB.create_table? :posts do
  primary_key :id
  String :text, text: true
  DateTime :created_at
  DateTime :updated_at
end

class Post < Sequel::Model(:posts)
end

Post.dataset_module do
  def all_sorted
        Post.reverse_order(:created_at)
    end
end
