class Link < ActiveRecord::Base
  acts_as_content_block :connectable => false
  
  named_scope :named, lambda{|name| {:conditions => ['links.name = ?', name]}}
  
  has_one :section_node, :as => :node, :dependent => :destroy, :inverse_of => :node

  validates_presence_of :name

  include Addressable
  include Addressable::DeprecatedPageAccessors

  #needed by menu_helper
  def path
    url
  end

end
