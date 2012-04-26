# Represents any object which exists in a Sitemap.
#
# Can have parents (using SectionNodes) and children.
module Cms
  module Addressable

    def self.included(model_class)
      model_class.attr_accessible :parent
    end

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
      self.class.name.demodulize.underscore
    end

    # Pages/Links/Attachments use their parent to determine access
    module LeafNode
      def access_status
        parent.status
      end
    end

    module NodeAccessors
      def node
        section_node
      end

      def node=(n)
        self.section_node = n
      end
    end
    # These exist for backwards compatibility to avoid having to change tests.
    # I want to get rid of these in favor of parent and parent_id
    module DeprecatedPageAccessors

      def self.included(model_class)
        model_class.attr_accessible :section_id, :section
      end
      include LeafNode
      include NodeAccessors

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
end