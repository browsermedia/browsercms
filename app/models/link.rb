class Link < ActiveRecord::Base
  acts_as_content_object
  
  has_one :section_node, :as => :node
  
  validates_presence_of :name
  validates_format_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix

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

end