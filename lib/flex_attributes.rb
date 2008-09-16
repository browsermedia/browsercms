module FlexAttributes

  def self.included(base) # :nodoc:
      base.extend ClassMethods
  end

  # Flex attributes allow for the common but questionable database design of
  # storing attributes in a thin key/value table related to some model.
  #
  # = Rational
  #
  # A good example of this is where you need to store
  # lots (possible hundreds) of optional attributes on an object. My typical
  # reference example is when you have a User object. You want to store the
  # user's preferences between sessions. Every search, sort, etc in your
  # application you want to keep track of so when the user visits that section
  # of the application again you can simply restore the display to how it was.
  #
  # So your controller might have:
  #
  #   Project.find :all, :conditions => current_user.project_search,
  #     :order => current_user.project_order
  #
  # But there could be hundreds of these little attributes that you really don't
  # want to store directly on the user object. It would make your table have too
  # many columns so it would be too much of a pain to deal with. Also there might
  # be performance problems. So instead you might do something like
  # this:
  #
  #   class User < ActiveRecord::Base
  #     has_many :preferences
  #   end
  #
  #   class Preferences < ActiveRecord::Base
  #     belongs_to :user
  #   end
  #
  # Now simply give the Preference model a "name" and "value" column and you are
  # set..... except this is now too complicated. To retrieve a attribute you will
  # need to do something like:
  #
  #   Project.find :all,
  #     :conditions => current_user.preferences.find_by_name('project_search').value,
  #     :order => current_user.preferences.find_by_name('project_order').value
  #
  # Sure you could fix this through a few methods on your model. But what about
  # saving?
  #
  #   current_user.preferences.create :name => 'project_search',
  #     :value => "lastname LIKE 'jones%'"
  #   current_user.preferences.create :name => 'project_order',
  #     :value => "name"
  #
  # Again this seems to much. Again we could add some methods to our model to
  # make this simpler but do we want to do this on every model. NO! So instead
  # we use this plugin which does everything for us.
  #
  # = Capabilities
  #
  # The FlexAttributes plugin is capable of modeling this problem in a intuitive
  # way. Instead of having to deal with a related model you treat all attributes
  # (both on the model and related) as if they are all on the model. The plugin
  # will try to save all attributes to the model (normal ActiveRecord behaviour)
  # but if there is no column for an attribute it will try to save it to a
  # related model whose purpose is to store these many sparsly populated
  # attributes.
  #
  # The main design goals are:
  #
  # * Have the flex attributes feel like normal attributes. Simple gets and sets
  #   will add and remove records from the related model.
  # * Allow for more than one related model. So for example on my User model I might
  #   have some flex attributes going into a contact_info table while others are
  #   going in a user_preferences table.
  # * Allow a model to determine what a valid flex attribute is for a given
  #   related model so our model still can generate a NoMethodError.
  # * Have flex attributes work with ActsAsVersioned. We want the versioned
  #   models to be able to be related with the correct attributes. If a flex
  #   attribute changes it should generate a new version of the model and the old
  #   version should still have the old value for the flex attribute.


  module ClassMethods

    # Will make the current class have flex attributes.
    #
    #   class User < ActiveRecord::Base
    #     has_flex_attributes
    #   end
    #   eric = User.find_by_login 'eric'
    #   puts "My AOL instant message name is: #{eric.aim}"
    #   eric.phone = '555-123-4567'
    #   eric.save
    #
    # The above example should work even though "aim" and "phone" are not
    # attributes on the User model.
    #
    # The following options are available on for has_flex_attributes to modify
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
    #   A list of fields that are valid flex attributes. By default
    #   this is "nil" which means that all field are valid. Use this option if
    #   you want some fields to go to one flex attribute model while other
    #   fields will go to another. As an alternative you can override the
    #   #flex_attributes method which will return a list of all valid flex
    #   attributes. This is useful if you want to read the list of attributes
    #   from another source to keep your code DRY. This method is given a
    #   single argument which is the class for the related model. The following
    #   provide an example:
    #
    #  class User < ActiveRecord::Base
    #    has_flex_attributes :class_name => 'UserContactInfo'
    #    has_flex_attributes :class_name => 'Preferences'
    #
    #    def flex_attributes(model)
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
    # certain that only the above flex attributes are allowed.
    #
    # If both a :fields option and #flex_attributes method is defined the
    # :fields option take precidence. This allows you to easily define the
    # field list inline for one model while implementing #flex_attributes
    # for another model and not having #flex_attributes need to determine
    # what model it is answering for. In both cases the list of flex
    # attributes can be a list of string or symbols
    #
    # A final alternative to :fields and #flex_attributes is the
    # #is_flex_attribute? method. This method is given two arguments. The
    # first is the attribute being retrieved/saved the second is the Model we
    # are testing for. If you override this method then the #flex_attributes
    # method or the :fields option will have no affect. Use of this method
    # is ideal when you want to retrict the attributes but do so in a
    # algorithmic way. The following is an example:
    #   class User < ActiveRecord::Base
    #     has_flex_attributes :class_name => 'UserContactInfo'
    #     has_flex_attributes :class_name => 'Preferences'
    #
    #     def is_flex_attribute?(attr, model)
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
    def has_flex_attributes(options={})

      # Provide default options
      options[:class_name] ||= self.class_name + 'Attribute'
      options[:table_name] ||= options[:class_name].tableize
      options[:relationship_name] ||= options[:class_name].tableize.to_sym
      options[:foreign_key] ||= self.class_name.foreign_key
      options[:base_foreign_key] ||= self.name.underscore.foreign_key
      options[:name_field] ||= 'name'
      options[:value_field] ||= 'value'
      options[:fields].collect! {|f| f.to_s} unless options[:fields].nil?
      options[:versioned] = options.has_key?(:versioned) ?
        options[:versioned] : false

      # Init option storage if necessary
      cattr_accessor :flex_options
      self.flex_options ||= Hash.new

      # Return if already processed.
      return if self.flex_options.keys.include? options[:class_name]

      # Attempt to load related class. If not create it
      begin
        options[:class_name].constantize
      rescue
        Object.const_set(options[:class_name],
          Class.new(ActiveRecord::Base)).class_eval do
          def self.reloadable? #:nodoc:
            false
          end
        end
      end

      # Store options
      self.flex_options[options[:class_name]] = options

      # Mix in instance methods
      send :include, FlexAttributes::InstanceMethods

      # Modify attribute class
      attribute_class = options[:class_name].constantize
      base_class = self.name.underscore.to_sym
      attribute_class.class_eval do
        belongs_to base_class, :foreign_key => options[:base_foreign_key]
        alias_method :base, base_class # For generic access
        if options[:versioned]
          begin
            version_column = column_names.include?('lock_version') ?
              'lock_version' : 'version'
            def version # :nodoc:
              lock_version
            end if version_column == 'lock_version'
          rescue
            version_column = 'version'
          end
          acts_as_versioned :version_column => version_column
          acts_as_versioned_association base_class, :both_sides => true
          def version_condition_met? # :nodoc:
            base.version_condition_met?
          end
        end
      end

      # Modify main class
      class_eval do
        has_many options[:relationship_name],
          :class_name => options[:class_name],
          :table_name => options[:table_name],
          :foreign_key => options[:foreign_key],
          :dependent => :destroy

        if options[:versioned]
          begin
            version_column = column_names.include?('lock_version') ?
              'lock_version' : 'version'
            def version # :nodoc:
              lock_version
            end if version_column == 'lock_version'
          rescue
            version_column = 'version'
          end
          acts_as_versioned :version_column => version_column
          acts_as_versioned_association options[:relationship_name],
            :both_sides => true
          version_class.send :include,
            FlexAttributes::InstanceMethods
        end

        # The following is only setup once
        unless private_method_defined? :method_missing_without_flex_attributes

          # Carry out delayed actions before save
          after_validation_on_update :save_modified_flex_attributes

          # Make attributes seem real
          alias_method :method_missing_without_flex_attributes, :method_missing
          alias_method :method_missing, :method_missing_with_flex_attributes

          if options[:versioned]
            version_class_alias_method :method_missing_without_flex_attributes, :method_missing
            version_class_alias_method :method_missing, :method_missing_with_flex_attributes
          end

          private

          alias_method :read_attribute_without_flex_attributes, :read_attribute
          alias_method :read_attribute, :read_attribute_with_flex_attributes
          alias_method :write_attribute_without_flex_attributes, :write_attribute
          alias_method :write_attribute, :write_attribute_with_flex_attributes

          if options[:versioned]
            version_class_alias_method :read_attribute_without_flex_attributes, :read_attribute
            version_class_alias_method :read_attribute, :read_attribute_with_flex_attributes
            version_class_alias_method :write_attribute_without_flex_attributes, :write_attribute
            version_class_alias_method :write_attribute, :write_attribute_with_flex_attributes
          end
        end
      end
    end

    private

    # Will alias a method on the versioned class
    def version_class_alias_method(new, old)
      version_class.send(:alias_method, new, old)
    end

    # Will return the version class when dealing with a versioned object
    def version_class
      "#{name}::Version".constantize
    end
  end

  module InstanceMethods

    # Will determine if the given attribute is a flex attribute on the
    # given model. Override this in your class to provide custom logic if
    # the #flex_attributes method or the :fields option are not flexible
    # enough. If you override this method :fields and #flex_attributes will
    # not apply at all unless you implement them yourself.
    def is_flex_attribute?(attr, model)
      attr = attr.to_s
      return flex_options[model.name][:fields].include?(attr) unless
        flex_options[model.name][:fields].nil?
      return flex_attributes(model).collect {|f| f.to_s}.include?(attr) unless
        flex_attributes(model).nil?
      true
    end

    # Return a list of valid flex attributes for the given model. Return
    # nil if any field is allowed. If you want to say no field is allowed
    # then return an empty array. If you just have a static list the :fields
    # option is most likely easier.
    def flex_attributes(model); nil end

    private

    # Called after validation on update so that flex attributes behave
    # like normal attributes in the fact that the database is not touched
    # until save is called.
    def save_modified_flex_attributes
      return if @save_flex_attr.nil?
      @save_flex_attr.each do |s|
        model, attr_name = s
        related_attr = flex_related_attr model, attr_name
        unless related_attr.nil?
          if related_attr.value.nil?
            flex_related(model).delete related_attr
          else
            related_attr.save
          end
        end
      end
      @save_flex_attr = []
    end

    # Overrides ActiveRecord::Base#read_attribute
    def read_attribute_with_flex_attributes(attr_name)
      attr_name = attr_name.to_s
      exec_if_related attr_name do |model|
        return nil if !@remove_flex_attr.nil? && @remove_flex_attr.any? do |r|
          r[0] == model && r[1] == attr_name
        end
        value_field = flex_options[model.name][:value_field]
        related_attr = flex_related_attr model, attr_name
        return nil if related_attr.nil?
        return related_attr.send(value_field)
      end
      read_attribute_without_flex_attributes(attr_name)
    end

    # Overrides ActiveRecord::Base#write_attribute
    def write_attribute_with_flex_attributes(attr_name, value)
      attr_name = attr_name.to_s
      exec_if_related attr_name do |model|
        value_field = flex_options[model.name][:value_field]
        @save_flex_attr ||= []
        @save_flex_attr << [model, attr_name]
        related_attr = flex_related_attr(model, attr_name)
        if related_attr.nil?
          # Used to check for nil? but this caused validation
          # problems that are harder to solve. blank? is probably
          # not correct but it works well for now.
          unless value.blank?
            name_field = flex_options[model.name][:name_field]
            foreign_key = flex_options[model.name][:foreign_key]
            flex_related(model).build name_field => attr_name,
              value_field => value, foreign_key => self.id
          end
          return value
        else
          value_field = (value_field.to_s + '=').to_sym
          return related_attr.send(value_field, value)
        end
      end
      write_attribute_without_flex_attributes(attr_name, value)
    end

    # Implements flex-attributes as if real getter/setter methods
    # were defined.
    def method_missing_with_flex_attributes(method_id, *args, &block)
      begin
        method_missing_without_flex_attributes method_id, *args, &block
      rescue NoMethodError => e
        attr_name = method_id.to_s.sub(/\=$/, '')
        exec_if_related attr_name do |model|
          if method_id.to_s =~ /\=$/
            return write_attribute_with_flex_attributes(attr_name, args[0])
          else
            return read_attribute_with_flex_attributes(attr_name)
          end
        end
        raise e
      end
    end

    # Retrieve the related flex attribute object
    def flex_related_attr(model, attr)
        name_field = flex_options[model.name][:name_field]
        flex_related(model).to_a.find {|r| r.send(name_field) == attr}
    end

    # Retrieve the collection of related flex attributes
    def flex_related(model)
      relationship = flex_options[model.name][:relationship_name]
      send relationship
    end

    # Yield only if attr_name is a flex_attribute
    def exec_if_related(attr_name)
      return false if self.class.column_names.include? attr_name
      each_flex_relation do |model|
        if is_flex_attribute?(attr_name, model)
          yield model
        end
      end
    end

    # Yields for each flex relation.
    def each_flex_relation
      flex_options.keys.each {|kls| yield kls.constantize}
    end

    # Returns the options for the flex attributes
    def flex_options
      nonversioned_class(self.class).flex_options
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