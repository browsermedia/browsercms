class AbstractFileBlock < ActiveRecord::Base
  set_table_name "file_blocks"
  
  attr_accessor :file, :section

  belongs_to :file_metadata, :polymorphic => true

  before_save :save_file
  
  def section_id=(section_id)
    self.section = Section.find(section_id)
  end
  
  def section_id
    return section.id unless section.nil?
    file_metadata.section_id unless file_metadata.nil?
  end
  
  def path
    [file_metadata.section.path, "#{file_metadata.id}_#{file_metadata.file_name}"].join("/").gsub(/\/{2,}/,"/")
  end

  def save_file
    unless file.blank?
      self.file_metadata = FileMetadata.create!(:file => file, :section => section)
    end
  end

end