class BlogPost < ActiveRecord::Base
  acts_as_content_block :taggable => true
  belongs_to :blog
  belongs_to :author, :class_name => "User"
  has_many :comments, :class_name => "BlogComment"
  
  def self.default_order
    "created_at desc"
  end
  
  def self.columns_for_index
    [ {:label => "Name", :method => :name },
      {:label => "Published", :method => :published_label } ]
  end  
  
  def published_label
    published_at ? published_at.to_s(:date) : nil
  end
  
end