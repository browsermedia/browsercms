class Cms::Page < ActiveRecord::Base

  def actual_path
    path
  end

  is_archivable
  flush_cache_on_change
  is_hideable
  is_publishable
  uses_soft_delete
  is_userstamped
  is_versioned

  has_many :connectors, :class_name => 'Cms::Connector', :order => "#{Cms::Connector.table_name}.container, #{Cms::Connector.table_name}.position"
  has_many :page_routes, :class_name => 'Cms::PageRoute'
  has_many :tasks

  include Cms::DefaultAccessible
  attr_accessible :name, :path, :template_file_name, :hidden, :cacheable # Needs to be explicit so seed data will work.

  scope :named, lambda { |name| {:conditions => ["#{table_name}.name = ?", name]} }
  scope :with_path, lambda { |path| {:conditions => ["#{table_name}.path = ?", path]} }

  # This scope will accept a connectable object or a Hash.  The Hash is expect to have
  # a value for the key :connectable, which is the connectable object, and possibly
  # a value for the key :version.  The Hash contains a versioned connectable object,
  # it will use the value in :version if present, otherwise it will use the version 
  # of the object.  In either case of a connectable object or a Hash, if the object
  # is not versioned, no version will be used
  scope :connected_to, lambda { |b|
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
      {:include => :connectors,
       :conditions => ["#{Cms::Connector.table_name}.connectable_id = ? and #{Cms::Connector.table_name}.connectable_type = ? and #{Cms::Connector.table_name}.connectable_version = ?", obj.id, obj.class.base_class.name, ver]}
    else
      {:include => :connectors,
       :conditions => ["#{Cms::Connector.table_name}.connectable_id = ? and #{Cms::Connector.table_name}.connectable_type = ?", obj.id, obj.class.base_class.name]}
    end
  }

  # currently_connected_to tightens the scope of connected_to by restricting to the 
  # results to matches on current versions of pages only.  This renders obj versions
  # useless, as the older objects will very likely have older versions of pages and
  # thus return no results.
  scope :currently_connected_to, lambda { |obj|
    connectors_table = Cms::Connector.table_name

    ver = obj.class.versioned? ? obj.version : nil
    if ver
      {:include => :connectors,
       :conditions => ["#{connectors_table}.connectable_id = ? and #{connectors_table}.connectable_type = ? and #{connectors_table}.connectable_version = ? and #{connectors_table}.page_version = #{Cms::Page.table_name}.version", obj.id, obj.class.base_class.name, ver]}
    else
      {:include => :connectors,
       :conditions => ["#{connectors_table}.connectable_id = ? and #{connectors_table}.connectable_type = ? and #{connectors_table}.page_version = #{Cms::Page.table_name}.version", obj.id, obj.class.base_class.name]}
    end
  }

  has_one :section_node, :as => :node, :dependent => :destroy, :inverse_of => :node, :class_name => 'Cms::SectionNode'


  include Cms::Addressable
  include Cms::Addressable::DeprecatedPageAccessors


  before_validation :append_leading_slash_to_path, :remove_trailing_slash_from_path
  before_destroy :delete_connectors

  validates_presence_of :name, :path

  # Paths must be unique among undeleted records
  validates_uniqueness_of :path, :scope=>:deleted
  validate :path_not_reserved

  # Implements Versioning Callback.
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

  # Each time a page is updated, we need to copy all connectors associated with it forward, and save
  # them.
  def copy_connectors(options={})
    logger.debug { "Copying connectors from Page #{id} v#{options[:from_version_number]} to v#{options[:to_version_number]}." }

    c_found = connectors.for_page_version(options[:from_version_number]).all(:order => "#{Cms::Connector.table_name}.container, #{Cms::Connector.table_name}.position")
    logger.debug { "Found connectors #{c_found}" }
    c_found.each do |c|

      # The connector won't have a connectable if it has been deleted
      # Also need to see if the draft has been deleted,
      # in which case we are in the process of deleting it
      if c.should_be_copied?
        logger.debug { "Connector id=>#{c.id} should be copied." }
        connectable = c.connectable_type.constantize.versioned? ? c.connectable.as_of_version(c.connectable_version) : c.connectable
        version = connectable.class.versioned? ? connectable.version : nil

        #If we are copying connectors from a previous version, that means we are reverting this page,
        #in which case we should create a new version of the block, and connect this page to that block.
        #If the connectable is versioned, the connector needs to reference the newly drafted connector
        #that is created during the revert_to method
        if @copy_connectors_from_version && connectable.class.versioned? && (connectable.version != connectable.draft.version)
          connectable = connectable.class.find(connectable.id)
          connectable.updated_by_page = self
          connectable.revert_to(c.connectable_version)
          version = connectable.class.versioned? ? connectable.draft.version : nil
        end

        logger.debug "When copying block #{connectable.inspect} version is '#{version}'"

        new_connector = connectors.create(
          :page_version => options[:to_version_number],
          :connectable => connectable, 
          :connectable_version => version,
          :container => c.container,
          :position => c.position
        )
        logger.debug { "Built new connector #{new_connector}." }
      end
    end
    true
  end

  # Adds a Content block to this page.
  # @param [ContentBlock] connectable The content block to be added
  # @param [Symbol] container The container to add it in (default :main)
  def add_content(connectable, container=:main)
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

  alias_method :create_connector, :add_content

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

  # Pages that get deleted should be 'disconnected' from any blocks they were associated with.
  def delete_connectors
    connectors.for_page_version(version).all.each { |c| c.destroy }
  end

  #This is done to let copy_connectors know which version to pull from
  #copy_connectors will get called later as an after_update callback
  def revert_to(version)
    @copy_connectors_from_version = version
    super(version)
  end

  # Pages have no size (for the purposes of FCKEditor)
  def file_size
    "NA"
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
    elsif path[0, 1] != "/"
      self.path = "/#{path}"
    end
  end

  # remove trailing slash, unless the path is only a slash.  uses capture and
  # substition because ruby regex engine does not support lookbehind
  def remove_trailing_slash_from_path
    self.path.sub!(/(.+)\/+$/, '\1')
  end

  def path_not_reserved
    if Cms.reserved_paths.include?(path)
      errors.add(:path, "is invalid, '#{path}' a reserved path")
    end
  end

  # Return the layout used to render this page. Will be something like: 'templates/subpage'
  # @param [Symbol] version Valid values are :full and :mobile.
  def layout(version = :full)
    folder = (version == :mobile) ? "mobile" : "templates"
    template_file_name && "#{folder}/#{layout_name}"
  end

  # Return the file name of the template
  def layout_name
    template_file_name.split('.').first
  end

  # This will be nil if it is a file system based template
  def template
    Cms::PageTemplate.find_by_file_name(template_file_name)
  end

  def template_name
    template_file_name && Cms::PageTemplate.display_name(template_file_name)
  end

  # Determines if a page is a descendant of a given Section.
  #
  # @param [String | Section] section_or_section_name
  def in_section?(section_or_section_name)
    found = false
    ancestors.each do |a|
      if section_or_section_name.is_a?(String)
        if a.name == section_or_section_name
          found = true
          break
        end
      else
        if a == section_or_section_name
          found = true
          break
        end
      end
    end
    found
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
    (a[1..a.size].map { |a| a.name } + [name]).join(" / ")
  end

  # This will return the "top level section" for this page, which is the section directly
  # below the root (a.k.a My Site) that this page is in.  If this page is in root,
  # then this will return root.
  #
  # @return [Section] The first non-root ancestor if available, root otherwise.
  def top_level_section
    # Cache the results of this since many projects will call it repeatly on current_page in menus.
    return @top_level_section if @top_level_section
    a = ancestors
    @top_level_section = (a.size > 0 && a[1]) ? a[1] : Cms::Section.root.first
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
