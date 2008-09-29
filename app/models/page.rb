class Page < ActiveRecord::Base
  
  acts_as_content_page
  versioned_class.belongs_to :updated_by, :class_name => "User"
  
  attr_accessor :updated_by_user
  
  belongs_to :updated_by, :class_name => "User"
  belongs_to :section
  belongs_to :template, :class_name => "PageTemplate"
  has_many :connectors, :conditions => 'page_version = #{version}', :order => "position"
  
  before_validation :set_updated_by
  before_validation :append_leading_slash_to_path
  before_destroy :delete_connectors
  
  validates_presence_of :section_id, :updated_by_id
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
  
  def destroy_connector(connector)
    transaction do
      new_connectors = []
      connectors.each do |c|
        unless c == connector
          con = Connector.new(c.attributes)
          con.id = nil
          new_connectors << con
        end
      end
      increment_version!
      
      new_connectors.each do |c|
        c.page_version = version
        c.save!
      end
      reload
      connector.freeze
    end
  end
  
  def delete_connectors
    Connector.delete_all "page_id = #{id}"
  end
  
  def append_leading_slash_to_path
    if path.blank?
      self.path = "/"
    elsif path[0,1] != "/"
      self.path = "/#{path}"
    end
  end
  
  #We set the value of the the association to the value in the virtual attriute
  #This makes sute that updated_by_user is explictly set on each update
  def set_updated_by
    self.updated_by = updated_by_user
  end
  
  def move_to(section, user)
    self.section = section
    self.updated_by_user = user
    save
  end
  
  def layout
    template ? template.file_name : nil
  end

  def template_name
    template ? template.name : nil
  end
  
end