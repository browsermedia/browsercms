class Cms::Link < ActiveRecord::Base
  acts_as_content_block :connectable => false

  scope :named, lambda{|name| {:conditions => ["#{table_name}.name = ?", name]}}

  validates_presence_of :name

  is_addressable
  include Cms::Concerns::Addressable::DeprecatedPageAccessors

  #needed by menu_helper
  def path
    url
  end

end
