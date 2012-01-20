class Section < ActiveRecord::Base

  include Addressable
  flush_cache_on_change

  #The node that links this section to its parent
  has_one :section_node, :class_name => "SectionNode", :as => :node, :inverse_of => :node
  def node
    section_node
  end
  def node=(n)
    self.section_node = n
  end
  # Cannot use dependent => :destroy to do this. Ancestry's callbacks trigger before the before_destroy callback. So sections always get deleted.
  after_destroy :destroy_node
  before_destroy :deletable?

  has_many :group_sections
  has_many :groups, :through => :group_sections

  named_scope :root, :conditions => ['root = ?', true]
  named_scope :system, :conditions => {:name => 'system'}

  named_scope :hidden, :conditions => {:hidden => true}
  named_scope :not_hidden, :conditions => {:hidden => false}

  named_scope :named, lambda { |name| {:conditions => ['sections.name = ?', name]} }
  named_scope :with_path, lambda { |path| {:conditions => ['sections.path = ?', path]} }

  validates_presence_of :name, :path

  # Disabling '/' in section name for interoperability with FCKEditor file browser
  validates_format_of :name, :with => /\A[^\/]*\Z/, :message => "cannot contain '/'"

  validate :path_not_reserved

  attr_accessor :full_path

  delegate :ancestry_path, :to => :node

  def ancestry
    self.node.ancestry
  end

  def before_validation
    unless node
      self.node = build_section_node
    end
  end

  # Returns a list of all children which are sections.
  # @return [Array<Section>]
  def sections
    child_sections = self.node.children.collect do |section_node|
      section_node.node if section_node.section?
    end
    child_sections.compact
  end

  alias :child_sections :sections

  # Since #sections isn't an association anymore, callers can use this rather than #sections.build
  def build_section
    Section.new(:parent=>self)
  end

  # Used by the sitemap to find children to iterate over.
  def child_nodes
    self.node.children
  end

  def pages
    child_pages = self.node.children.collect do |section_node|
      section_node.node if section_node.page?
    end
    child_pages.compact
  end

  # 'Navigation' children are items which should appear in a sitemap, including pages, sections and links.
  # @return [Array<Addressable>]
  def navigation_children
    query = node.children.of_type(["Page", "Link", "Section"]).fetch_nodes.in_order
    query.collect { |section_node|
      addressable = section_node.node
      addressable.cache_node_id = section_node.id
      addressable.cache_parent self
      addressable
    }
  end

  def visible_child_nodes(options={})
    children = child_nodes.of_type(["Section", "Page", "Link"]).all(:order => 'section_nodes.position')
    visible_children = children.select { |sn| sn.visible? }
    options[:limit] ? visible_children[0...options[:limit]] : visible_children
  end


  # This method is probably unnecessary. Could be rewritten to have each section be able to known its own page.
  # @todo - Replace this with #sections and add a #full_path to Section
  def all_children_with_name
    sections.map do |section|
      section.full_path = root? ? section.name : "#{name} / #{section.name}"
      [section] << section.all_children_with_name
    end.flatten.compact
  end

  def parent_id
    parent ? parent.id : nil
  end

  def parent_id=(sec_id)
    self.parent = Section.find(sec_id)
  end

  def with_ancestors(options = {})
    options.merge! :include_self => true
    self.ancestors(options)
  end

  def move_to(section)
    if root?
      false
    else
      node.move_to_end(section)
    end
  end

  def public?
    !!(groups.find_by_code('guest'))
  end

  def empty?
    child_nodes.empty?
  end

  # Callback to determine if this section can be deleted.
  def deletable?
    !root? && empty?
  end

  # Callback to clean up related nodes
  def destroy_node
    node.destroy
  end

  def editable_by_group?(group)
    group.editable_by_section(self)
  end

  def status
    @status ||= public? ? :unlocked : :locked
  end

  # Used by the file browser to look up a section by the combined names as a path.
  #   i.e. /A/B/
  # @return [Section] nil if not found
  def self.find_by_name_path(name_path)
    current_section = Section.root.first
    path_names = name_path.split("/")[1..-1] || []

    # This implementation is very slow as it has to loop over the entire tree in memory to match each name element.
    path_names.each do |name|
      current_section.sections.each do |s|
        current_section = s if s.name == name
      end
    end
    current_section
  end

  #The first page that is a decendent of this section
  def first_page_or_link
    section_node = child_nodes.of_type(['Link', 'Page']).first(:order => "section_nodes.position")
    return section_node.node if section_node
    sections.each do |s|
      node = s.first_page_or_link
      return node if node
    end
    nil
  end

  def actual_path
    if root?
      "/"
    else
      p = first_page_or_link
      p ? p.path : "#"
    end
  end

  def path_not_reserved
    if Cms.reserved_paths.include?(path)
      errors.add(:path, "is invalid, '#{path}' a reserved path")
    end
  end

  ##
  # Set which groups are allowed to access this section.
  # @params [Symbol] code Set of groups to allow (Options :all, :none) Defaults to :none
  def allow_groups=(code=:none)
    if code == :all
      self.groups = Group.all
    end
  end
end
