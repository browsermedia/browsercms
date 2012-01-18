class AbstractFileBlock < ActiveRecord::Base
  
  set_table_name "file_blocks"
      
  validates_presence_of :name  
  
  named_scope :by_section, lambda { |section| {
      :include => {:attachment => :section_node },
      :conditions => ["section_nodes.ancestry = ?", section.node.ancestry_path] }
  }
  
  def path
    attachment_file_path
  end
  
  def self.publishable?
    true
  end

  def set_attachment_path
    if @attachment_file_path && @attachment_file_path != attachment.file_path
      attachment.file_path = @attachment_file_path
    end
  end

  def set_attachment_section
    if @attachment_section_id && @attachment_section_id != attachment.section
      attachment.section_id = @attachment_section_id
    end
  end

end