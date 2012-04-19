class Catalog < ActiveRecord::Base
  acts_as_content_block

  has_many_attachments :photos
end
