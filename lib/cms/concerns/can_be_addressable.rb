module Cms
  module Concerns
    module CanBeAddressable

      # Adds Addressable behavior to a model. This allows models to be inserted into the sitemap, having parent
      # sections. By default, this method is available to all ActiveRecord::Base classes.
      #
      # @params [Hash] options
      # @option options [String] :path The base path where instances will be placed.
      # @option options [String] :no_dynamic_path Set as true if the Record has a :path attribute managed as a column in the db. (Default: false)
      def is_addressable(options={})
        has_one_options = {as: :node, inverse_of: :node, class_name: 'Cms::SectionNode'}
        if options[:dependent]
          has_one_options[:dependent] = options[:dependent]
        end
        has_one :section_node, has_one_options

        include Cms::Concerns::Addressable
        extend Cms::Concerns::Addressable::ClassMethods
        include Cms::Concerns::Addressable::NodeAccessors

        if options[:path]
          @path = options[:path]
        end

        unless options[:no_dynamic_path]
          include Addressable::DynamicPath
        end
      end

    end

    module Addressable

      module ClassMethods

        # The base path where new records will be added.
        def path
          @path
        end
      end

      module DynamicPath

        # @return [String] The relative path to this content
        def path
          "#{self.class.path}/#{slug}"
        end
      end

      def self.included(model_class)
        model_class.attr_accessible :parent
      end

      # Returns the value that will appear in the <title> element of the page when this content is rendered.
      # Subclasses can override this.
      #
      # @return [String]
      # @example Override the page title
      #   class MyWidget < ActiveRecord::Base
      #     def page_title
      #       "My Widget | #{name}"
      #     end
      #   end
      def page_title
        name
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

      # alias :node, :section_node
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
end