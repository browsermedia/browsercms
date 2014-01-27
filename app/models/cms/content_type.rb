module Cms
  class ContentType

    attr_accessor :name

    def initialize(options)
      self.name = options[:name]
      @path_builder = EngineAwarePathBuilder.new(model_class)
    end

    attr_accessor :path_builder
    delegate :main_app_model?, :engine_name, :engine_class, to: :path_builder

    DEFAULT_CONTENT_TYPE_NAME = 'Cms::HtmlBlock'

    class << self
      def named(name)
        [Cms::ContentType.new(name: name)]
      end

      def connectable
        available.select { |content_type| content_type.connectable? }
      end

      # Return all content types, grouped by module.
      #
      # @return [Hash<Symbol, Cms::ContentType]
      def available_by_module
        modules = {}
        available.each do |content_type|

          modules[content_type.module_name] = [] unless modules[content_type.module_name]
          modules[content_type.module_name] << content_type
        end
        modules
      end

      # Returns a list of all ContentTypes in the system. Content Types can opt out of this list by specifying:
      #
      #   class MyWidget < ActiveRecord::Base
      #     acts_as_content content_module: false
      #   end
      #
      # Ignores the database to just look at classes, then returns a 'new' ContentType to match.
      #
      # @return [Array<Cms::ContentType] An alphabetical list of content types.
      def available
        subclasses = ObjectSpace.each_object(::Class).select do |klass|
          klass < Cms::Concerns::HasContentType::InstanceMethods
        end
        subclasses << Cms::Portlet
        subclasses.uniq! { |k| k.name } # filter duplicate classes
        subclasses.map do |klass|
          unless klass < Cms::Portlet
            Cms::ContentType.new(name: klass.name)
          end
        end.compact.sort { |a, b| a.name <=> b.name }
      end

      def list
        available
      end

      # Returns all content types besides the default.
      #
      # @return [Array<Cms::ContentType]
      def other_connectables()
        available.select { |content_type| content_type.name != DEFAULT_CONTENT_TYPE_NAME }
      end

      # Returns the default content type that is most frequently added to pages.
      def default()
        Cms::ContentType.new(name: DEFAULT_CONTENT_TYPE_NAME)
      end

      # Returns only user generated Content Blocks
      def user_generated_connectables()
        available.select { |content_type| !content_type.name.starts_with?("Cms::") }
      end

      # Return content types that can be accessed as pages.
      def addressable()
        available.select { |content_type| content_type.model_class.addressable? }
      end
    end


    # Given a 'key' like 'html_blocks' or 'portlet'. Looks first for a class in the Cms:: namespace, then again without it.
    # Raises exception if nothing was found.
    def self.find_by_key(key)
      class_name = key.tableize.classify
      klass = nil
      prefix = "Cms::"
      if !class_name.starts_with? prefix
        klass = "Cms::#{class_name}".safe_constantize
      end
      unless klass
        klass = class_name.safe_constantize
      end
      unless klass
        if class_name.starts_with?(prefix)
          klass = class_name[prefix.length, class_name.length].safe_constantize
        end
      end
      unless klass
        raise "Couldn't find ContentType for '#{key}'. Checked for classes Cms::#{class_name} and #{class_name}."
      end
      klass.content_type
    end

    # Returns a list of column names and values for this content type which are allowed be orderable.
    def orderable_attributes
      attribute_names = model_class.new.attribute_names
      attribute_names -= ["id", "version", "lock_version", "created_by_id", "updated_by_id"]
    end

    # @deprecated
    def save!
      ActiveSupport::Deprecation.warn "Cms::ContentType#save! should no longer be called. Content Types do not need to be registered in the database."
    end

    def self.create!
      ActiveSupport::Deprecation.warn "Cms::ContentType.create! should no longer be called. Content Types do not need to be registered in the database."
    end

    # Return the name of the module this content type should be grouped in. In most cases, content blocks will be
    # configured to specify this.
    # @return [Symbol]
    def module_name
      model_class.content_module
    end

    # Returns the partial used to render the form fields for a given block.
    def form
      model_class.respond_to?(:form) ? model_class.form : "#{name.underscore.pluralize}/form"
    end

    def display_name
      model_class.respond_to?(:display_name) ? model_class.display_name : Cms::Behaviors::Connecting.default_naming_for(model_class)
    end

    def display_name_plural
      model_class.respond_to?(:display_name_plural) ? model_class.display_name_plural : display_name.pluralize
    end

    def model_class
      name.constantize
    end

    # Determines if the content can be connected to other pages.
    def connectable?
      model_class.connectable?
    end

    # Cms::HtmlBlock -> html_block
    # ThingBlock -> thing_block
    def param_key
      model_class.model_name.param_key
    end

    # Allows models to show additional columns when being shown in a list.
    def columns_for_index
      if model_class.respond_to?(:columns_for_index)
        model_class.columns_for_index.map do |column|
          column.respond_to?(:humanize) ? {:label => column.humanize, :method => column} : column
        end
      else
        [{:label => "Name", :method => :name, :order => "name"},
         {:label => "Updated On", :method => :updated_on_string, :order => "updated_at"}]
      end
    end

    # Used in ERB for pathing
    def content_block_type
      n = name.starts_with?("Cms::") ? name.demodulize : name
      n.pluralize.underscore
    end

    # This is used for situations where you want different to use a type for the list page
    # This is true for portlets, where you don't want to list all portlets of a given type,
    # You want to list all portlets
    def content_block_type_for_list
      if model_class.respond_to?(:content_block_type_for_list)
        model_class.content_block_type_for_list
      else
        content_block_type
      end
    end

  end
end