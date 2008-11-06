class AbstractFileBlock < ActiveRecord::Base
  set_table_name "file_blocks"
  
  attr_accessor :file, :file_name
  
  belongs_to :attachment

  before_validation :process_attachment

  validates_presence_of :name
  
  def validate
    unless attachment.valid?
      attachment.errors.each do |err_field, err_value|
        errors.add(:file_name, err_value)
      end      
    end
  end
  
  named_scope :by_section, lambda { |section| { :include => :attachment, :conditions => ["attachment.section_id = ?", section.id] } }
  
  def path
    attachment.file_name
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

  def process_attachment
    if new_record? && (attachment.nil? || attachment.new_record?)
      build_attachment
      attachment.file = file
      attachment.file_name = file_name
    end
  end

end