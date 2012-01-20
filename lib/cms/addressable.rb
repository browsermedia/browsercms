# Represents any object which exists in a Sitemap.
#
# Can have parents (using SectionNodes) and children.
module Addressable

  # Returns a list of all Addressable objects that are ancestors to this record.
  # @param [Hash] options
  # @option [Symbol] :include_self If this object should be included in the Array
  # @return [Array<Addressable]
  #
  def ancestors(options={})
    ancestor_nodes = node.ancestors
    ancestors = ancestor_nodes.collect { |node| node.node }
    ancestors << self if options[:include_self]
    ancestors
  end

  def cache_node_id=(id)
    @sitemap_node_id = id
  end

  # Returns the id of the section_node for this object. Used by the sitemap to handle moving.
  # Section#navigation_children will set this when looking up children, which prevents double loading of nodes
  #   Since Rails 2.x lacks an identity map, this call sequence will trigger extra calls:
  #
  #   sn = Section.find(3, :include=>:node) # 2 queries: one for section_node, one for page
  #   page = sn.node    # No query (page already loaded)
  #   n = page.node     # 1 query: SectionNode 3 gets fetched again.
  def sitemap_node_id
    @sitemap_node_id ? @sitemap_node_id : node.id
  end

  def parent
    @parent if @parent
    node ? node.section : nil
  end

  def cache_parent(section)
    @parent = section
  end

  def parent=(sec)
    if node
      node.move_to_end(sec)
    else
      build_section_node(:node => self, :section => sec)
    end
  end

  # Computes the name of the partial used to render this object in the sitemap.
  def partial_for
    self.class.name.underscore
  end

  # Pages/Links/Attachments use their parent to determine access
  module LeafNode
    def access_status
      parent.status
    end
  end

  # These exist for backwards compatibility to avoid having to change tests.
  # I want to get rid of these in favor of parent and parent_id
  module DeprecatedPageAccessors
    include LeafNode

    def node
      section_node
    end

    def build_node(opts)
      build_section_node(opts)
    end

    def section_id
      section ? section.id : nil
    end

    def section_id=(sec_id)
      self.section = Section.find(sec_id)
    end

    def section
      parent
    end

    def section=(sec)
      self.parent = sec

    end
  end
end