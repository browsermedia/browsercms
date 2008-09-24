class AbstractFileBlock < ActiveRecord::Base
  set_table_name "file_blocks"
  
  attr_accessor :file, :section

  belongs_to :file_metadata, :polymorphic => true

  before_save :save_file
  
  def path
    [section.path, "#{file_metadata.id}_#{file_metadata.file_name}"].join("/").gsub(/\/{2,}/,"/")
  end

  def save_file
    unless file.blank?
      self.file_metadata = FileMetadata.create!(:file => file, :section => section)
    end
  end

end