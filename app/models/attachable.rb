#The main reason this module exists is that we need to control the order in which callbacks are define
#and also the call to acts_as_content_object needs to be in the subclasses of AbstractFileBlock
module Attachable
  def self.included(file_block_class)
    file_block_class.class_eval do
      attr_accessor :file, :file_name
      before_save :update_attachment_if_changed
      before_validation :process_attachment  
      belongs_to :attachment      
    end
  end
  def validate
    unless attachment.valid?
      attachment.errors.each do |err_field, err_value|
        if err_field.to_sym == :file_name
          errors.add(:file_name, err_value)
        else  
          errors.add(:file, err_value)
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
    build_attachment if attachment.nil?
    attachment.file = file if file
    attachment.file_name = file_name if file_name
  end

  def update_attachment_if_changed
    attachment.updated_by = updated_by_user
    #attachment.archived = archived
    attachment.published = !!(publish_on_save)
    attachment.save if new_record? || attachment.changed? || attachment.file
    self.attachment_version = attachment.version
  end
  
  #Size in kilobytes
  def file_size
    attachment ? "%0.2f" % (attachment.file_size / 1024.0) : "?"
  end
  
  def after_as_of_version
    self.attachment = Attachment.find(attachment_id).as_of_version(attachment_version)
  end
  
end