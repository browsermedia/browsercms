class Page < ActiveRecord::Base
  
  is_archivable
  flush_cache_on_change
  is_hideable
  is_publishable
  uses_soft_delete
  is_userstamped
  is_versioned
  
  has_many :connectors, :order => "connectors.container, connectors.position"
  has_many :page_routes
  
  named_scope :named, lambda{|name| {:conditions => ['pages.name = ?', name]}}
  named_scope :with_path, lambda{|path| {:conditions => ['pages.path = ?', path]}}
  
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
  validates_uniqueness_of :path
  validate :path_not_reserved
          
  def after_build_new_version(new_version)
    copy_connectors(
      :from_version_number => @copy_connectors_from_version || (new_version.version - 1),
      :to_version_number => new_version.version
    )
    @copy_connectors_from_version = nil
    true
  end
  
  # Publish all
  def after_publish
    self.reload # Get's the correct version number loaded
    self.connectors.for_page_version(self.version).all(:order => "position").each do |c| 
      if c.connectable_type.constantize.publishable? && con = c.connectable
        con.publish
      end
    end
  end
  
  def copy_connectors(options={})
    connectors.for_page_version(options[:from_version_number]).all(:order => "connectors.container, connectors.position").each do |c|
      # The connector won't have a connectable if it has been deleted
      # Also need to see if the draft has been deleted,
      # in which case we are in the process of deleting it
      if c.should_be_copied?
        connectable = c.connectable_type.constantize.versioned? ? c.connectable.as_of_version(c.connectable_version) : c.connectable
      
        #If we are copying connectors from a previous version, that means we are reverting this page,
        #in which case we should create a new version of the block, and connect this page to that block
        if @copy_connectors_from_version && connectable.class.versioned? && (connectable.version != connectable.draft.version)
          connectable = connectable.class.find(connectable.id)
          connectable.updated_by_page = self
          connectable.revert_to(c.connectable_version)
        end      
      
        new_connector = connectors.build(
          :page_version => options[:to_version_number], 
          :connectable => connectable, 
          :connectable_version => connectable.class.versioned? ? connectable.version : nil,         
          :container => c.container, 
          :position => c.position
        )
      end
    end
    true
  end  
  
  def create_connector(connectable, container)
    transaction do
      raise "Connectable is nil" unless connectable
      raise "Container is required" if container.blank?
      update_attributes(
        :version_comment => "#{connectable} was added to the '#{container}' container",
        :publish_on_save => (
          published? && 
          connectable.connected_page && 
          (connectable.class.publishable? ? connectable.published? : true)))
      connectors.create(
        :page_version => draft.version,
        :connectable => connectable,
        :connectable_version => connectable.class.versioned? ? connectable.version : nil, 
        :container => container)      
    end
  end

  def move_connector(connector, direction)
    transaction do
      raise "Connector is nil" unless connector
      raise "Direction is nil" unless direction
      orientation = direction[/_/] ? "#{direction.sub('_', ' the ')} of" : "#{direction} within"
      update_attributes(:version_comment => "#{connector.connectable} was moved #{orientation} the '#{connector.container}' container")
      connectors.for_page_version(draft.version).like(connector).first.send("move_#{direction}")
    end    
  end
    
  %w(up down to_top to_bottom).each do |d|
    define_method("move_connector_#{d}") do |connector|
      move_connector(connector, d)
    end
  end
  
  def remove_connector(connector)
    transaction do
      raise "Connector is nil" unless connector
      update_attributes(:version_comment => "#{connector.connectable} was removed from the '#{connector.container}' container")
      
      #The logic of this is to go ahead and let the container get copied forward, then delete the new connector
      if new_connector = connectors.for_page_version(draft.version).like(connector).first
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
  def revert_to(version)
    @copy_connectors_from_version = version
    super(version)
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
      
  def append_leading_slash_to_path
    if path.blank?
      self.path = "/"
    elsif path[0,1] != "/"
      self.path = "/#{path}"
    end
  end
  
  def path_not_reserved
    if Cms.reserved_paths.include?(path)
      errors.add(:path, "is invalid, '#{path}' a reserved path")
    end
  end
      
  def layout
    template_file_name && "templates/#{template_file_name.split('.').first}"
  end
  
  # This will be nil if it is a file system based template
  def template
    PageTemplate.find_by_file_name(template_file_name)
  end
  
  def template_name
    template_file_name && PageTemplate.display_name(template_file_name)
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
    connectors.for_page_version(draft.version).in_container(container.to_s).all? do |c| 
      c.connectable_type.constantize.publishable? ? c.connectable.live? : true
    end
  end
  
  # Returns the number of connectables in the given container for this version of this page
  def connectable_count_for_container(container)
    connectors.for_page_version(version).in_container(container.to_s).count
  end
    
  def self.find_live_by_path(path)
    published.not_archived.first(:conditions => {:path => path})
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

