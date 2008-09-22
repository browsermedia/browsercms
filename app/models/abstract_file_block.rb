class AbstractFileBlock < ActiveRecord::Base
  set_table_name "file_blocks"
  
  attr_accessor :file
  
  belongs_to :cms_file, :polymorphic => true
  belongs_to :section
  
  before_save :save_file
  
  def path
    [section.path, cms_file.file_name].join("/").gsub(/\/{2,}/,"/")
  end
  
end