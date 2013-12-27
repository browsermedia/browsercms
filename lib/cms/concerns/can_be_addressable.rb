module Cms
  module Concerns
    module CanBeAddressable

      # Adds Addressable behavior to a model. This allows models to be inserted into the sitemap, having parent
      # sections. By default, this method is available to all ActiveRecord::Base classes.
      #
      # @params [Hash] options
      # @option options [String] :path The base path where instances will be placed.
      # @option options [String] :no_dynamic_path Set as true if the Record has a :path attribute managed as a column in the db. (Default: false)
      # @option options [Symbol] :destroy_if Name of a custom method used to determine when this object should be destroyed. Rather than dependant: destroy to determine if the section node should be destroyed when this object is.
      def is_addressable(options={})
        has_one_options = {as: :node, inverse_of: :node, class_name: 'Cms::SectionNode', validate: true}
        unless options[:destroy_if]
          has_one_options[:dependent] = :destroy
        else
          before_destroy options[:destroy_if]
          after_destroy :destroy_node
        end

        has_one :section_node, has_one_options
        # For reasons that aren't clear, just using :autosave doesn't work.
        after_save do
          if section_node && section_node.changed?
            section_node.save
          end
        end

        after_validation do
          # Copy errors from association for slug
          if section_node && !section_node.valid?
            section_node.errors[:slug].each do |message|
              errors.add(:slug, message)
            end
          end
        end

        include Cms::Concerns::Addressable
        extend Cms::Concerns::Addressable::ClassMethods
        include Cms::Concerns::Addressable::NodeAccessors
        include Cms::Concerns::Addressable::MarkAsDirty
        extend Cms::Configuration::ConfigurableTemplate

        if options[:path]
          @path = options[:path]
          include GenericSitemapBehavior
        end

        @template = options[:template]

        unless options[:no_dynamic_path]
          include Addressable::DynamicPath
        end
      end

      # @return [Boolean] Until is_addressable is called, this will always be false.
      def addressable?
        false
      end

      # @return [Boolean] Some addressable content types don't require a slug.
      def requires_slug?
        false
      end
    end

    # Implements behavior for displaying content blocks that should appear in the sitemap.
    #
    module GenericSitemapBehavior
      def self.included(klass)
        klass.before_validation :assign_parent_if_needed
      end

      def partial_for
        "addressable_content_block"
      end

      def hidden?
        false
      end

      def assign_parent_if_needed
        unless parent || parent_id
          new_parent = Cms::Section.with_path(self.class.path).first

          unless new_parent
            logger.warn "Creating default section for #{self.try(:display_name)} in #{self.class.path}."
            section_attributes = {:name => self.class.name.demodulize.pluralize,
                                  :path => self.class.path,
                                  :hidden => true,
                                  allow_groups: :all}
            section_parent = Cms::Section.root.first
            if section_parent
              section_attributes[:parent] = section_parent
            end
            new_parent = Cms::Section.create!(section_attributes)
          end
          self.parent_id = new_parent.id
        end
      end
    end

    module Addressable

      module ClassMethods

        def requires_slug?
          !@path.nil?
        end

        # The base path where new records will be added.
        # @return [String]
        def path
          @path
        end

        # @return [Boolean] Once is_addressable is called, this will always be true.
        def addressable?
          true
        end

        def calculate_path(slug)
          "#{self.path}/#{slug}"
        end

        # Used in UI forms to show what the complete URL will look like with a slug added to it.
        def base_path
          "#{self.path}/"
        end

        # Find an addressable object with the given content type.
        #
        # @param [String] slug
        # @return [Addressable] The content block with that slug (if it exists). Nil otherwise
        def with_slug(slug)
          section_node = SectionNode.where(slug: slug).where(node_type: self.name).first
          section_node ? section_node.node : nil
        end

        # Returns the layout (Page Template) that should be used to render instances of this content.
        # Can be specified as is_addressable template: 'subpage'
        # @return [String] template/default unless template was set.
        def layout
          normalize_layout(self, @template)
        end
      end

      module DynamicPath

        # @return [String] The relative path to this content
        def path
          self.class.calculate_path(slug)
        end

        def slug
          if section_node
            section_node.slug
          else
            nil
          end
        end

        def slug=(slug)
          if section_node
            section_node.slug = slug
          else
            @slug = slug # Store temporarily until there is a section_node created.
          end
          dirty!
        end
      end

      # Resources are accessible to guests if their parent section is. Variables are passed in for performance reasons
      # since this gets called 'MANY' times on the sitemap.
      #
      # @param [Array<Section>] public_sections
      # @param [Section] parent
      def accessible_to_guests?(public_sections, parent)
        public_sections.include?(parent)
      end

      # Returns all classes which need a custom route to show themselves.
      def self.classes_that_require_custom_routes
        descendants.select { |klass| klass.path != nil }
      end

      # List of all classes that can be in the sitemap.
      #
      # @return [Array<Class>] Returns all classes which inherit from Cms::Concerns::Addressable
      def self.descendants
        ObjectSpace.each_object(::Class).select { |klass| klass < Cms::Concerns::Addressable }
      end

      # Allows for manual destruction of node
      def destroy_node
        node.destroy
      end

      # Whether or not this content is the 'landing' page for its section.
      #
      # @return [Boolean] false always, since a content block won't ever be the landing page for the section
      def landing_page?
        false
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
      # @return [Array<Addressable>] Or [] if no ancestors and/or has no parent.
      #
      def ancestors(options={})
        return [] unless node
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

      def parent_id
        parent.try(:id)
      end

      def parent_id=(id)
        self.parent = Cms::Section.find(id)
        # Handles slug being set before there is a parent
        if @slug
          self.slug = @slug
          @slug = nil
        end
      end

      def parent=(sec)
        if node
          node.move_to_end(sec)
        else
          build_section_node(:node_id => self.id, :section => sec)
        end
      end

      # Computes the name of the partial used to render this object in the sitemap.
      def partial_for
        self.class.name.demodulize.underscore
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
          #model_class.attr_accessible :section_id, :section
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

      # Allows records to be marked as being changed, which can be called to trigger updates when
      # associated objects may have been changed.
      module MarkAsDirty
        # Forces this record to be changed, even if nothing has changed
        # This is necessary if just the section.id has changed, for example
        # test if this is necessary now that the attributes are in the
        # model itself.
        def dirty!
          # Seems like a hack, is there a better way?
          self.updated_at = Time.now
        end
      end
    end


  end
end