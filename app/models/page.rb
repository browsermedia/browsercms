class Page < ActiveRecord::Base
  
  acts_as_content_page
  
  version_fu
    
  belongs_to :section
  belongs_to :template, :class_name => "PageTemplate"
  has_many :connectors, :conditions => 'page_version = #{version}', :order => "position"
  
  before_validation :append_leading_slash_to_path
  before_destroy :delete_connectors
  
  validates_presence_of :section_id
  validates_uniqueness_of :path
  
  def add_content_block!(content_block, container)
    transaction do
      new_connectors = connectors.map do |c|
        con = Connector.new(c.attributes)
        con.id = nil
        con
      end
      increment_version!
      new_connectors << Connector.new(:page => self, 
        :content_block => content_block, 
        :content_block_version => content_block.version,
        :container => container)
      new_connectors.each do |c|
        c.page_version = version
        c.save!
      end
      reload
      new_connectors.last
    end
  end
  
  def delete_connectors
    logger.info "deleting connectors"
    Connector.delete_all "page_id = #{id}"
  end
  
  def append_leading_slash_to_path
    if path.blank?
      self.path = "/"
    elsif path[0,1] != "/"
      self.path = "/#{path}"
    end
  end
  
  def move_to(section)
    self.section = section
    save
  end
  
  def layout
    template ? template.file_name : nil
  end

  def template_name
    template ? template.name : nil
  end
  
end