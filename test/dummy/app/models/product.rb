# This is a sample content type that mimics how content blocks are generated with project status.
class Product < ActiveRecord::Base
    acts_as_content_block
end
