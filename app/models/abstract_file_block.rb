class AbstractFileBlock < ActiveRecord::Base
  set_table_name "file_blocks"
  
  belongs_to :attachment

  after_create :set_name
  validates_presence_of :name, :on => :update

  #Note that it is important that the create_new_attachment callback
  #run before the callbacks defined in acts_as_content_block
  #If not, the versioning will not work as expected
  #that is also why this is a before_save and not a before_update
  #Apparently in rails, when updating a record,
  #all before_save's are called in the order they are defined,
  #then all before_updates's are called in the order they are defined
  before_save :create_new_attachment
  
  named_scope :by_section, lambda { |section| { :include => :attachment, :conditions => ["attachment.section_id = ?", section.id] } }
  
  def path
    [attachment.section.path, attachment.file_name].join("/").gsub(/\/{2,}/,"/")
  end

  def file_size
    attachment ? "%0.2f" % (attachment.file_size / 1024.0) : "?"
  end

  #Delagate getter/setters for attachment
  def section
    attachment.section unless attachment.nil?
  end

  def section_id
    attachment.section_id unless attachment.nil?
  end

  def section=(section)
    build_attachment if new_record? && attachment.nil?
    attachment.section = section
  end

  def section_id=(section_id)
    build_attachment if new_record? && attachment.nil?
    attachment.section_id = section_id
  end

  def file=(file)
    build_attachment if new_record? && attachment.nil?
    attachment.file = file
    @attachment_changed = true
  end

  def create_new_attachment
    unless new_record?
      if attachment.changed? || @attachment_changed
        new_attachment = Attachment.new(attachment.attributes.without("id"))
        new_attachment.updating_file!
        new_attachment.file = attachment.file      
        new_attachment.save!
        self.attachment = new_attachment
      end
    end
  end

  def set_name
    update_attribute(:name, attachment.file_name) if name.blank?
  end

end