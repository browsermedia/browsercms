class BlogComment < ActiveRecord::Base
  belongs_to :post, :class_name => "BlogPost"
end