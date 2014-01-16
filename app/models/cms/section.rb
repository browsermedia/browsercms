module Cms
  class Section < ActiveRecord::Base
    flush_cache_on_change

    is_addressable no_dynamic_path: true, destroy_if: :deletable?
    # Cannot use dependent => :destroy to do this. Ancestry's callbacks trigger before the before_destroy callback.
    #   So sections would always get deleted since deletable? would return true
    after_destroy :destroy_node
    before_destroy :deletable?

    SECTION = "Cms::Section"
    PAGE = "Cms::Page"
    LINK = "Cms::Link"
    VISIBLE_NODE_TYPES = [SECTION, PAGE, LINK]
    HIDDEN_NODE_TYPES = "Cms::Attachment"

    extend DefaultAccessible
    # @override
    def self.permitted_params
      super + [:allow_groups, group_ids: []]
    end

    has_many :group_sections, :class_name => 'Cms::GroupSection'
    has_many :groups, :through => :group_sections, :class_name => 'Cms::Group'

    scope :root, -> { where(['root = ?', true]) }
    scope :system, -> { where({:name => 'system'}) }
    scope :hidden, -> { where({:hidden => true}) }
    scope :not_hidden, -> { where({:hidden => false}) }

    def self.named(name)
      where(["#{table_name}.name = ?", name])
    end

    def self.with_path(path)
      where(["#{table_name}.path = ?", path])
    end

    #scope :named, lambda { |name| {-> {where( ["#{table_name}.name = ?", name]} }   )}
    #scope :with_path, lambda { |path| {-> {where( ["#{table_name}.path = ?", path]} }    )}

    validates_presence_of :name, :path

    # Disabling '/' in section name for interoperability with FCKEditor file browser
    validates_format_of :name, :with => /\A[^\/]*\Z/, :message => "cannot contain '/'"

    validate :path_not_reserved

    attr_accessor :full_path

    delegate :ancestry_path, :to => :node

    def ancestry
      self.node.ancestry
    end

    before_validation :ensure_section_node_exists

    def ensure_section_node_exists
      unless node
        self.node = build_section_node
      end
    end

    # Returns a list of all children which are sections.
    # @return [Array<Section>]
    def sections
      child_nodes.of_type(SECTION).fetch_nodes.in_order.collect do |section_node|
        section_node.node
      end
    end

    alias :child_sections :sections

    # Since #sections isn't an association anymore, callers can use this rather than #sections.build
    def build_section
      Section.new(:parent => self)
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

    def self.sitemap
      SectionNode.not_of_type(HIDDEN_NODE_TYPES).fetch_nodes.arrange(:order => :position)
    end

    def visible_child_nodes(options={})
      children = child_nodes.of_type(VISIBLE_NODE_TYPES).fetch_nodes.in_order.to_a
      visible_children = children.select { |sn| sn.visible? }
      options[:limit] ? visible_children[0...options[:limit]] : visible_children
    end


    # Returns a complete list of all sections that are desecendants of this sections, in order, as a single flat list.
    # Used by Section selectors where users have to pick a single section from a complete list of all sections.
    def master_section_list
      sections.map do |section|
        section.full_path = root? ? section.name : "#{name} / #{section.name}"
        [section] << section.master_section_list
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
      current_section = Cms::Section.root.first
      path_names = name_path.split("/")[1..-1] || []

      # This implementation is very slow as it has to loop over the entire tree in memory to match each name element.
      path_names.each do |name|
        current_section.sections.each do |s|
          current_section = s if s.name == name
        end
      end
      current_section
    end

    #The first page that is a descendent of this section
    def first_page_or_link
      types = Cms::ContentType.addressable.collect(&:name).push(LINK).push(PAGE)
      section_node = child_nodes.of_type(types).fetch_nodes.in_order.first
      return section_node.node if section_node
      sections.each do |s|
        node = s.first_page_or_link
        return node if node
      end
      nil
    end

    # Returns the path for this section with a trailing slash
    def prependable_path
      if path.ends_with?("/")
        path
      else
        "#{path}/"
      end
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
    # @param [Symbol] code Set of groups to allow (Options :all, :none) Defaults to :none
    def allow_groups=(code=:none)
      if code == :all
        self.groups = Cms::Group.all
      end
    end

    # Sections are accessible to guests if they marked as such. Variables are passed in for performance reasons
    # since this gets called 'MANY' times on the sitemap.
    #
    # @param [Array<Section>] public_sections
    # @param [Section] parent
    def accessible_to_guests?(public_sections, parent)
      public_sections.include?(self)
    end
  end
end