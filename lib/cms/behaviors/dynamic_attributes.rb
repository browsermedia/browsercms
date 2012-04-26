module Cms
  module Behaviors
    # The DynamicAttributes behavior allows a model to store values for any attributes.
    # A model that uses DynamicAttributes should have corresponding "_attributes" table
    # where it stores the values for the dynamic attributes.
    # This is based on the {Flex Attributes Rails Plugin}[http://rubyforge.org/projects/flex-attributes].
    #
    #   class User < ActiveRecord::Base
    #     has_dynamic_attributes
    #   end
    #   eric = User.find_by_login 'eric'
    #   puts "My AOL instant message name is: #{eric.aim}"
    #   eric.phone = '555-123-4567'
    #   eric.save
    #
    # The above example should work even though "aim" and "phone" are not
    # attributes on the User model.
    #
    # The following options are available on for has_dynamic_attributes to modify
    # the behavior. Reasonable defaults are provided:
    #
    # class_name::
    #   The class for the related model. This defaults to the
    #   model name prepended to "Attribute". So for a "User" model the class
    #   name would be "UserAttribute". The class can actually exist (in that
    #   case the model file will be loaded through Rails dependency system) or
    #   if it does not exist a basic model will be dynamically defined for you.
    #   This allows you to implement custom methods on the related class by
    #   simply defining the class manually.
    # table_name::
    #   The table for the related model. This defaults to the
    #   attribute model's table name.
    # relationship_name::
    #   This is the name of the actual has_many
    #   relationship. Most of the type this relationship will only be used
    #   indirectly but it is there if the user wants more raw access. This
    #   defaults to the class name underscored then pluralized finally turned
    #   into a symbol.
    # foreign_key::
    #   The key in the attribute table to relate back to the
    #   model. This defaults to the model name underscored prepended to "_id"
    # name_field::
    #   The field which stores the name of the attribute in the related object
    # value_field::
    #   The field that stores the value in the related object
    # fields::
    #   A list of fields that are valid dynamic attributes. By default
    #   this is "nil" which means that all field are valid. Use this option if
    #   you want some fields to go to one dynamic attribute model while other
    #   fields will go to another. As an alternative you can override the
    #   #dynamic_attributes method which will return a list of all valid dynamic
    #   attributes. This is useful if you want to read the list of attributes
    #   from another source to keep your code DRY. This method is given a
    #   single argument which is the class for the related model. The following
    #   provide an example:
    #
    #  class User < ActiveRecord::Base
    #    has_dynamic_attributes :class_name => 'UserContactInfo'
    #    has_dynamic_attributes :class_name => 'Preferences'
    #
    #    def dynamic_attributes(model)
    #      case model
    #        when UserContactInfo
    #          %w(email phone aim yahoo msn)
    #        when Preference
    #          %w(project_search project_order user_search user_order)
    #        else Array.new
    #      end
    #    end
    #  end
    #
    #  eric = User.find_by_login 'eric'
    #  eric.email = 'eric@example.com' # Will save to UserContactInfo model
    #  eric.project_order = 'name'     # Will save to Preference
    #  eric.save # Carries out save so now values are in database
    #
    # Note the else clause in our case statement. Since an empty array is
    # returned for all other models (perhaps added later) then we can be
    # certain that only the above dynamic attributes are allowed.
    #
    # If both a :fields option and #dynamic_attributes method is defined the
    # :fields option take precidence. This allows you to easily define the
    # field list inline for one model while implementing #dynamic_attributes
    # for another model and not having #dynamic_attributes need to determine
    # what model it is answering for. In both cases the list of dynamic
    # attributes can be a list of string or symbols
    #
    # A final alternative to :fields and #dynamic_attributes is the
    # #is_dynamic_attribute? method. This method is given two arguments. The
    # first is the attribute being retrieved/saved the second is the Model we
    # are testing for. If you override this method then the #dynamic_attributes
    # method or the :fields option will have no affect. Use of this method
    # is ideal when you want to retrict the attributes but do so in a
    # algorithmic way. The following is an example:
    #   class User < ActiveRecord::Base
    #     has_dynamic_attributes :class_name => 'UserContactInfo'
    #     has_dynamic_attributes :class_name => 'Preferences'
    #
    #     def is_dynamic_attribute?(attr, model)
    #       case attr.to_s
    #         when /^contact_/ then true
    #         when /^preference_/ then true
    #         else
    #           false
    #       end
    #     end
    #   end
    #
    #   eric = User.find_by_login 'eric'
    #   eric.contact_phone = '555-123-4567'
    #   eric.contact_email = 'eric@example.com'
    #   eric.preference_project_order = 'name'
    #   eric.some_attribute = 'blah'  # If some_attribute is not defined on
    #                                 # the model then method not found is thrown
    module DynamicAttributes
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end

      module MacroMethods
        def has_dynamic_attributes?
          !!@has_dynamic_attributes
        end

        # Will make the current class have dynamic attributes.
        def has_dynamic_attributes(options={})
          @has_dynamic_attributes = true
          include InstanceMethods

          # Provide default options
          options[:class_name] ||= self.model_name + 'Attribute'
          options[:table_name] ||= options[:class_name].tableize
          options[:relationship_name] ||= options[:class_name].tableize.to_sym
          options[:foreign_key] ||= self.model_name.foreign_key
          options[:base_foreign_key] ||= self.name.underscore.foreign_key
          options[:name_field] ||= 'name'
          options[:value_field] ||= 'value'
          options[:fields].collect! { |f| f.to_s } unless options[:fields].nil?

          # Init option storage if necessary
          cattr_accessor :dynamic_options
          self.dynamic_options ||= Hash.new

          # Return if already processed.
          return if self.dynamic_options.keys.include? options[:class_name]

          # Attempt to load related class. If not create it
          begin
            options[:class_name].constantize
          rescue
            Object.const_set(options[:class_name], Class.new(ActiveRecord::Base)).class_eval do
              self.table_name = options[:table_name]
              self.mass_assignment_sanitizer = Cms::IgnoreSanitizer.new

              def self.reloadable? #:nodoc:
                false
              end
            end
          end

          # Store options
          self.dynamic_options[options[:class_name]] = options

          # Modify attribute class
          attribute_class = options[:class_name].constantize
          base_class = self.name.underscore.to_sym
          attribute_class.class_eval do
            belongs_to base_class, :foreign_key => options[:base_foreign_key]
            alias_method :base, base_class # For generic access
            attr_accessible :name, :value, "#{base_class.to_s}_id".to_sym
          end

          # Modify main class
          class_eval do
            has_many options[:relationship_name],
                     :class_name => options[:class_name],
                     :foreign_key => options[:foreign_key],
                     :dependent => :destroy

            # The following is only setup once
            unless private_method_defined? :method_missing_without_dynamic_attributes

              # Carry out delayed actions before save
              after_validation :save_modified_dynamic_attributes

              # Make attributes seem real
              alias_method :method_missing_without_dynamic_attributes, :method_missing
              alias_method :method_missing, :method_missing_with_dynamic_attributes

              private

              alias_method :read_attribute_without_dynamic_attributes, :read_attribute
              alias_method :read_attribute, :read_attribute_with_dynamic_attributes
              alias_method :write_attribute_without_dynamic_attributes, :write_attribute
              alias_method :write_attribute, :write_attribute_with_dynamic_attributes

            end
          end


        end
      end
      module InstanceMethods
        # Will determine if the given attribute is a dynamic attribute on the
        # given model. Override this in your class to provide custom logic if
        # the #dynamic_attributes method or the :fields option are not flexible
        # enough. If you override this method :fields and #dynamic_attributes will
        # not apply at all unless you implement them yourself.
        def is_dynamic_attribute?(attr, model)
          attr = attr.to_s
          return dynamic_options[model.name][:fields].include?(attr) unless dynamic_options[model.name][:fields].nil?
          return dynamic_attributes(model).collect { |f| f.to_s }.include?(attr) unless dynamic_attributes(model).nil?
          true
        end

        # Return a list of valid dynamic attributes for the given model. Return
        # nil if any field is allowed. If you want to say no field is allowed
        # then return an empty array. If you just have a static list the :fields
        # option is most likely easier.
        def dynamic_attributes(model)
          ; nil
        end


        # Overrides the assign_attributes= defined in ActiveRecord::Base(active_record/base.rb)
        #
        # The only difference is that this doesn't check to see if the
        # model responds_to the method before sending it
        #
        # Not happy with this copy/paste duplication, but its merely an update to the previous Rails 2/3 behavior
        # Must remain PUBLIC so other rails methods can call it (like ActiveRecord::Persistence#update_attributes)
        def assign_attributes(new_attributes, options = {})
          return unless new_attributes

          attributes = new_attributes.stringify_keys
          role = options[:as] || :default

          multi_parameter_attributes = []

          # Disabling mass assignment protection for attributes, might be a terrible idea, but dynamic_attributes are really wonky.
          #unless options[:without_protection]
          #  attributes = sanitize_for_mass_assignment(attributes, role)
          #end

          attributes.each do |k, v|
            if k.include?("(")
              multi_parameter_attributes << [k, v]
            else
              # Dynamic Attributes will take ALL setters (unlike ActiveRecord)
              send("#{k}=", v)
            end
          end

          assign_multiparameter_attributes(multi_parameter_attributes)
        end
      end

      private

      # Called after validation on update so that dynamic attributes behave
      # like normal attributes in the fact that the database is not touched
      # until save is called.
      def save_modified_dynamic_attributes
        return if new_record?
        return if @save_dynamic_attr.nil?
        @save_dynamic_attr.each do |s|
          model, attr_name = s
          related_attr = dynamic_related_attr model, attr_name
          unless related_attr.nil?
            if related_attr.value.nil?
              dynamic_related(model).delete related_attr
            else
              related_attr.save
            end
          end
        end
        @save_dynamic_attr = []
      end

      # Overrides ActiveRecord::Base#read_attribute
      def read_attribute_with_dynamic_attributes(attr_name)
        attr_name = attr_name.to_s
        exec_if_related attr_name do |model|
          return nil if !@remove_dynamic_attr.nil? && @remove_dynamic_attr.any? do |r|
            r[0] == model && r[1] == attr_name
          end
          value_field = dynamic_options[model.name][:value_field]
          related_attr = dynamic_related_attr model, attr_name
          return nil if related_attr.nil?
          return related_attr.send(value_field)
        end
        read_attribute_without_dynamic_attributes(attr_name)
      end

      # Overrides ActiveRecord::Base#write_attribute
      def write_attribute_with_dynamic_attributes(attr_name, value)
        attr_name = attr_name.to_s
        exec_if_related attr_name do |model|
          value_field = dynamic_options[model.name][:value_field]
          @save_dynamic_attr ||= []
          @save_dynamic_attr << [model, attr_name]
          related_attr = dynamic_related_attr(model, attr_name)
          if related_attr.nil?
            # Used to check for nil? but this caused validation
            # problems that are harder to solve. blank? is probably
            # not correct but it works well for now.
            unless value.blank?
              name_field = dynamic_options[model.name][:name_field]
              foreign_key = dynamic_options[model.name][:foreign_key]
              dynamic_related(model).build name_field => attr_name,
                                           value_field => value, foreign_key => self.id
            end
            return value
          else
            value_field = (value_field.to_s + '=').to_sym
            return related_attr.send(value_field, value)
          end
        end
        write_attribute_without_dynamic_attributes(attr_name, value)
      end

      # Implements dynamic-attributes as if real getter/setter methods
      # were defined.
      def method_missing_with_dynamic_attributes(method_id, *args, &block)
        begin
          method_missing_without_dynamic_attributes method_id, *args, &block
        rescue NoMethodError => e
          attr_name = method_id.to_s.sub(/\=$/, '')
          exec_if_related attr_name do |model|
            if method_id.to_s =~ /\=$/
              return write_attribute_with_dynamic_attributes(attr_name, args[0])
            else
              return read_attribute_with_dynamic_attributes(attr_name)
            end
          end
          raise e
        end
      end

      # Retrieve the related dynamic attribute object
      def dynamic_related_attr(model, attr)
        name_field = dynamic_options[model.name][:name_field]
        dynamic_related(model).to_a.find { |r| r.send(name_field) == attr }
      end

      # Retrieve the collection of related dynamic attributes
      def dynamic_related(model)
        relationship = dynamic_options[model.name][:relationship_name]
        send relationship
      end

      # Yield only if attr_name is a dynamic_attribute
      def exec_if_related(attr_name)
        return false if self.class.column_names.include? attr_name
        each_dynamic_relation do |model|
          if is_dynamic_attribute?(attr_name, model)
            yield model
          end
        end
      end

      # Yields for each dynamic relation.
      def each_dynamic_relation
        dynamic_options.keys.each { |kls| yield kls.constantize }
      end

      # Returns the options for the dynamic attributes
      def dynamic_options
        nonversioned_class(self.class).dynamic_options
      end

      # Will return the parent model if kls is a versioned class
      def nonversioned_class(kls)
        if kls.name =~ /\:\:Version$/
          base_class = kls.name
          base_class.sub!(/\:\:Version$/, '')
          return base_class.constantize
        end
        kls
      end

    end
  end
end
