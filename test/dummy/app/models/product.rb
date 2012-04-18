# This is a sample content type that mimics how content blocks are generated with project status.
class Product < ActiveRecord::Base
  acts_as_content_block
  belongs_to_category

  has_attachment :photo_1, :url => ":attachment_file_path"
  has_attachment :photo_2, :url => ":attachment_file_path"

end
