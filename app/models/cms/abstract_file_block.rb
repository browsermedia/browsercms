module Cms
class AbstractFileBlock < ActiveRecord::Base
  
  set_table_name "cms_file_blocks"
      
  validates_presence_of :name  
  
  named_scope :by_section, lambda { |section| { :include => {:attachment => :section_node }, :conditions => ["#{SectionNode.table_name}.section_id = ?", section.id] } } 
  
  def path
    attachment_file_path
  end
  
  def self.publishable?
    true
  end

end
end