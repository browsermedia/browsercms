class Page < ActiveRecord::Base
  
  is_archivable
  flush_cache_on_change
  is_hideable
  is_publishable
  uses_soft_delete
  is_userstamped
  is_versioned
  
  has_many :connectors, :order => "connectors.container, connectors.position"
  
  # This scope will accept a connectable object or a Hash.  The Hash is expect to have
  # a value for the key :connectable, which is the connectable object, and possibly
  # a value for the key :version.  The Hash contains a versioned connectable object,
  # it will use the value in :version if present, otherwise it will use the version 
  # of the object.  In either case of a connectable object or a Hash, if the object
  # is not versioned, no version will be used
  named_scope :connected_to, lambda { |b| 
    if b.is_a?(Hash)
      obj = b[:connectable]
      if obj.class.versioned?
        ver = b[:version] ? b[:version] : obj.version
      else
        ver = nil
      end
    else
      obj = b
      ver = obj.class.versioned? ? obj.version : nil
    end
    
    if ver
      { :include => :connectors, 
        :conditions => ['connectors.connectable_id = ? and connectors.connectable_type = ? and connectors.connectable_version = ?', obj.id, obj.class.base_class.name, ver] }
    else
      { :include => :connectors, 
        :conditions => ['connectors.connectable_id = ? and connectors.connectable_type = ?', obj.id, obj.class.base_class.name] }    
    end 
  }  
  
  has_one :section_node, :as => :node
  
  has_many :tasks
  
  before_validation :append_leading_slash_to_path
  before_destroy :delete_connectors
  
  validates_presence_of :name, :path
  validate :path_unique?
  validate :path_not_reserved
          
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
  
  def path_not_reserved
    if Cms.reserved_paths.include?(path)
      errors.add(:path, "is invalid, '#{path}' a reserved path")
    end
  end
      
  def layout
    "templates/#{template_name.to_s.downcase.gsub(/\s/,'_')}"
  end
  
  def template_name
    template
  end

  def ancestors
    section_node.ancestors
  end
  
  def in_section?(section_or_section_name)
    sec = section_or_section_name.is_a?(String) ? 
      Section.first(:conditions => {:name => section_or_section_name}) : 
      section_or_section_name
    fn = lambda{|s| s ? (s == sec || fn.call(s.parent)) : false}
    fn.call(section)
  end
    
  #Returns true if the block attached to each connector in the given container are published
  def container_published?(container)
    connectors.for_page_version(version).in_container(container.to_s).all? do |c| 
      c.connectable_type.constantize.publishable? ? c.connectable.published? : true
    end
  end
  
  # Returns the number of connectables in the given container for this version of this page
  def connectable_count_for_container(container)
    connectors.for_page_version(version).in_container(container.to_s).count
  end
    
  def self.find_live_by_path(path)
    if page_version = Page::Version.first(:conditions => {
        :path => path, 
        :archived => false, 
        :published => true}, 
        :order => "version desc")
      page = page_version.page.as_of_version(page_version.version)
      page.live_version? ? page : nil
    end
  end
  
  def name_with_section_path
    a = ancestors
    (a[1..a.size].map{|a| a.name} + [name]).join(" / ")
  end
  
  # This will return the "top level section" for a page, which is the section directly
  # below the root (a.k.a My Site) that this page is in.  If this page is in root,
  # then this will return root.
  def top_level_section
    a = ancestors
    (a.size > 0 && ancestors[1]) ? ancestors[1] : Section.root.first
  end
  
  def current_task
    tasks.incomplete.first
  end
  
  def assigned_to
    current_task ? current_task.assigned_to : nil
  end
  
  def assigned_to?(user)
    assigned_to == user
  end
  
end