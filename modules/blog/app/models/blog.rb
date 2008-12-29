class Blog < ActiveRecord::Base
  has_many :posts, :class_name => "BlogPost"
end