#The main reason this module exists is that we need to control the order in which callbacks are define
#and also the call to acts_as_content_object needs to be in the subclasses of AbstractFileBlock
module Attachable
  def self.included(file_block_class)
    file_block_class.class_eval do
      attr_accessor :attachment_file, :attachment_file_name
      before_save :update_attachment_if_changed
      before_validation :process_attachment  
      before_validation :set_attachment_file_name
      before_validation :set_section
      belongs_to :attachment      
    end
  end
  def validate
    if attachment && !attachment.valid?
      attachment.errors.each do |err_field, err_value|
        if err_field.to_sym == :file_name
          errors.add(:attachment_file_name, err_value)
        else  
          errors.add(:attachment_file, err_value)
        end
      end      
    end
  end
  #Delagate getter/setters for attachment
  def section
    attachment.section unless attachment.nil?
  end

  def section_id
    attachment.section_id unless attachment.nil?
  end

  def section=(section)
    build_attachment if attachment.nil?
    attachment.section = section
  end

  def section_id=(section_id)
    build_attachment if attachment.nil?
    attachment.section_id = section_id
  end

  def process_attachment
    unless attachment_file.blank?
      build_attachment if attachment.nil?  
      attachment.file = attachment_file    
    end
  end

  def set_attachment_file_name
    attachment.file_name = attachment_file_name if attachment_file_name   
  end

  def set_section
    #Used if content block wants to automatically set the section
  end

  def update_attachment_if_changed
    if attachment
      attachment.updated_by = updated_by_user
      attachment.archived = archived
      attachment.published = !!(publish_on_save)
      attachment.save if new_record? || attachment.changed? || attachment.file
      self.attachment_version = attachment.version
    end
  end
  
  #Size in kilobytes
  def file_size
    attachment ? "%0.2f" % (attachment.file_size / 1024.0) : "?"
  end
  
  def after_as_of_version
    self.attachment = Attachment.find(attachment_id).as_of_version(attachment_version)
  end
  
  def attachment_path
    attachment ? attachment.file_name : nil   
  end
  
  def attachment_link
    if attachment
      live? ? attachment_path : "/cms/attachments/show/#{attachment_id}?version=#{attachment_version}"    
    else
      nil
    end  
  end
  
end