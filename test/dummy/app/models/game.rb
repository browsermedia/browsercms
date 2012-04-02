class Game < ActiveRecord::Base
  acts_as_content_block :has_attachments => true

  has_attachment :score
end
