class Page < ActiveRecord::Base
  
  is_archivable
  is_hideable
  is_publishable
  uses_soft_delete
  is_userstamped
  is_versioned
  
  has_many :connectors, :order => "connectors.container, connectors.position"
  named_scope :connected_to, lambda { |b| 
    if b.class.versioned?
      { :include => :connectors, 
        :conditions => ['connectors.connectable_id = ? and connectors.connectable_type = ? and connectors.connectable_version = ?', b.id, b.class.base_class.name, b.version] }
    else
      { :include => :connectors, 
        :conditions => ['connectors.connectable_id = ? and connectors.connectable_type = ?', b.id, b.class.base_class.name] }    
    end 
  }  
  
  has_one :section_node, :as => :node
  
  belongs_to :template, :class_name => "PageTemplate"
  
  before_validation :append_leading_slash_to_path
  before_destroy :delete_connectors
  
  validates_presence_of :name
  validate :path_unique?
          
  def after_build_new_version(new_version)
    copy_connectors
    true
  end  
  
  def copy_connectors
    copy_from_version = @copy_connectors_from_version ? @copy_connectors_from_version : version - 1
    
    connectors.for_page_version(copy_from_version).all(:order => "connectors.container, connectors.position").each do |c|
      connectable = c.connectable_type.constantize.versioned? ? c.connectable.as_of_version(c.connectable_version) : c.connectable
      
      #If are publishing this page, We need to publish the other page if it is not already published
      if published? && c.connectable_type.constantize.publishable? && !c.connectable.published?
        connectable.publish_by_page!(self)
      end      
      
      #If we are copying connectors from a previous version, that means we are reverting this page,
      #in which case we should create a new version of the block, and connect this page to that block
      if @copy_connectors_from_version && connectable.class.versioned? && !connectable.current_version?
        connectable = connectable.class.find(connectable.id)
        connectable.published_by_page = self if connectable.class.publishable?
        connectable.revert_to(c.connectable_version)
      end
      
      connectors.build(
        :page_version => version, 
        :connectable => connectable, 
        :connectable_version => connectable.class.versioned? ? connectable.version : nil,         
        :container => c.container, 
        :position => c.position
      )
    end
    
    @copy_connectors_from_version = nil    
    true
  end  
    
  def create_connector(connectable, container)
    transaction do
      raise "Connectable is nil" unless connectable
      raise "Container is required" if container.blank?
      update_attributes(:version_comment => "#{connectable} was added to the '#{container}' container",
        :publish_on_save => (published? && connectable.connected_page && 
          (connectable.class.publishable? ? connectable.published? : true)))
      Connector.create(
        :page => self,
        :page_version => version,
        :connectable => connectable,
        :connectable_version => connectable.class.versioned? ? connectable.version : nil, 
        :container => container)      
    end
  end  
  
  %w(up down to_top to_bottom).each do |d|
    define_method("move_connector_#{d}") do |connector|
      move_connector(connector, d)
    end
  end

  def move_connector(connector, direction)
    transaction do
      raise "Connector is nil" unless connector
      raise "Direction is nil" unless direction
      orientation = direction[/_/] ? "#{direction.sub('_', ' the ')} of" : "#{direction} within"
      update_attributes(:version_comment => "#{connector.connectable} was moved #{orientation} the '#{connector.container}' container")
      connectors.for_page_version(version).like(connector).first.send("move_#{direction}")
    end    
  end  
  
  def remove_connector(connector)
    transaction do
      raise "Connector is nil" unless connector
      update_attributes(:version_comment => "#{connector.connectable} was removed from the '#{connector.container}' container")
      
      #The logic of this is to go ahead and let the container get copied forward, then delete the new connector
      if new_connector = connectors.for_page_version(version).like(connector).first
        new_connector.destroy
      else
        raise "Error occurred while trying to remove connector #{connector.id}"
      end
    end
  end          
          
  def delete_connectors
    connectors.for_page_version(version).all.each{|c| c.destroy }
  end        
         
  #This is done to let copy_connectors know which version to pull from
  #copy_connectors will get called later as an after_update callback
  alias_method :original_revert_to, :revert_to
  def revert_to(version)
    @copy_connectors_from_version = version
    original_revert_to(version)
  end         
          
  def file_size
    "?"
  end
  
  def section_id
    section ? section.id : nil
  end
  
  def section
    section_node ? section_node.section : nil
  end
  
  def section_id=(sec_id)
    self.section = Section.find(sec_id)
  end
  
  def section=(sec)
    if section_node
      section_node.move_to_end(sec)
    else
      build_section_node(:node => self, :section => sec)
    end      
  end
  
  def public?
    section ? section.public? : false
  end
  
  def page_title
    title.blank? ? name : title
  end
  
  %w(up down to_top to_bottom).each do |d|
    define_method("move_connector_#{d}") do |connector|
      move_connector(connector, d)
    end
  end
    
  def append_leading_slash_to_path
    if path.blank?
      self.path = "/"
    elsif path[0,1] != "/"
      self.path = "/#{path}"
    end
  end
  
  def path_unique?
    conditions = ["path = ?", path]
    unless new_record?
      conditions.first << " and id != ?"
      conditions << id
    end
    if self.class.count(:conditions => conditions) > 0
      errors.add(:path, "must be unique")
    end
  end
      
  def layout
    template ? template.file_name : nil
  end

  def template_name
    template ? template.name : nil
  end
  
  def ancestors
    section_node.ancestors
  end
    
  #Returns true if the block attached to each connector in the given container are published
  def container_published?(container)
    connectors.for_page_version(version).in_container(container.to_s).all? do |c| 
      c.connectable_type.constantize.publishable? ? c.connectable.published? : true
    end
  end
    
  def self.find_live_by_path(path)
    page = find(:first, :conditions => {:path => path})
    page ? page.live_version : nil
  end
  
end