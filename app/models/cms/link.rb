class Cms::Link < ActiveRecord::Base
  acts_as_content_block :connectable => false

  scope :named, lambda{|name| {:conditions => ["#{table_name}.name = ?", name]}}
  
  has_one :section_node, :as => :node, :dependent => :destroy, :inverse_of => :node, :class_name => 'Cms::SectionNode'

  validates_presence_of :name

  include Cms::Addressable
  include Cms::Addressable::DeprecatedPageAccessors

  #needed by menu_helper
  def path
    url
  end

end
