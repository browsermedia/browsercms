class Dummy::Catalog < ActiveRecord::Base
  acts_as_content_block
  content_module :testing
  self.table_name = :catalogs
  is_addressable path: "/catalogs"

  has_many_attachments :photos, :styles => { :thumbnail => "50x50" }
end
