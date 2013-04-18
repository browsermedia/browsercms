# This is a sample content type that mimics how content blocks are generated with project status.
class Product < ActiveRecord::Base
  acts_as_content_block
  belongs_to_category

  is_addressable

  has_attachment :photo_1
  has_attachment :photo_2

  def path
    "/products/#{slug}"
  end

  def page_title
    "Product: #{name}"
  end

end
