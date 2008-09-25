class AbstractFileBlock < ActiveRecord::Base
  set_table_name "file_blocks"
  
  belongs_to :file_metadata

  #Note that it is important that the create_new_file_metadata callback
  #run before the callbacks defined in acts_as_content_block
  #If not, the versioning will not work as expected
  #that is also why this is a before_save and not a before_update
  #Apparently in rails, when updating a record,
  #all before_save's are called in the order they are defined,
  #then all before_updates's are called in the order they are defined
  before_save :create_new_file_metadata      
  
  def path
    [file_metadata.section.path, "#{file_metadata.id}_#{file_metadata.file_name}"].join("/").gsub(/\/{2,}/,"/")
  end

  #Delagate getter/setters for file_metadata
  def section
    file_metadata.section unless file_metadata.nil?
  end

  def section_id
    file_metadata.section_id unless file_metadata.nil?
  end

  def section=(section)
    build_file_metadata if new_record? && file_metadata.nil?
    file_metadata.section = section
  end

  def section_id=(section_id)
    build_file_metadata if new_record? && file_metadata.nil?
    file_metadata.section_id = section_id
  end

  def file=(file)
    build_file_metadata if new_record? && file_metadata.nil?
    file_metadata.file = file
    @file_metadata_changed = true
  end

  def create_new_file_metadata
    unless new_record?
      if file_metadata.changed? || @file_metadata_changed
        new_file_metadata = FileMetadata.new(file_metadata.attributes.without("id"))
        logger.info "\n\n\n#{file_metadata.file.inspect}\n\n\n"
        new_file_metadata.file = file_metadata.file      
        new_file_metadata.save!
        self.file_metadata = new_file_metadata
      end
    end
  end

end