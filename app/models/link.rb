class Link < ActiveRecord::Base
  acts_as_content_block
  
  named_scope :named, lambda{|name| {:conditions => ['links.name = ?', name]}}
  
  has_one :section_node, :as => :node, :dependent => :destroy
  
  validates_presence_of :name

  def section_id
    section ? section.id : nil
  end
  
  def section
    section_node ? section_node.section : nil
  end
  
  def section_id=(sec_id)
    self.section = Section.find(sec_id)
  end
  
  def section=(sec)
    if section_node
      section_node.move_to_end(sec)
    else
      build_section_node(:node => self, :section => sec)
    end      
  end

  #needed by menu_helper
  def path
    url
  end

end