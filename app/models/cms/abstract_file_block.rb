module Cms
class AbstractFileBlock < ActiveRecord::Base

  # Base table name. Will be namespaced if appropriate.
  set_table_name "file_blocks"
      
  validates_presence_of :name  
  
  scope :by_section, lambda { |section| { :include => {:attachment => :section_node }, :conditions => ["#{SectionNode.table_name}.section_id = ?", section.id] } }

  def path
    attachment_file_path
  end
  
  def self.publishable?
    true
  end

end
end