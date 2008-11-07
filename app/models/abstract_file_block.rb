class AbstractFileBlock < ActiveRecord::Base
  
  set_table_name "file_blocks"
      
  validates_presence_of :name  
  
  #TODO: Fix, Case 1781
  named_scope :by_section, lambda { |section| { :include => :attachment, :conditions => ["attachment.section_id = ?", section.id] } }
  
  def path
    live? ? attachment.file_name : "/cms/attachments/show/#{id}?version=#{version}"
  end

end