module Cms
  class Portlet < ActiveRecord::Base
    validates_presence_of :name
    is_searchable

    # These are here simply to temporarily hold these values
    # Makes it easy to pass them through the process of selecting a portlet type
    attr_accessor :connect_to_page_id, :connect_to_container, :controller
    attr_accessible :connect_to_page_id, :connect_to_container, :controller, :name

    delegate :request, :response, :session,
             :flash, :params, :cookies,
             :current_user, :logged_in?,
             :to => :controller

    def self.inherited(subclass)
      super if defined? super
    ensure
      subclass.class_eval do

        # Using the table prefix here is NOT tested, since unloading classes is hard during tests.
        has_dynamic_attributes :class_name => "CmsPortletAttribute",
                               :foreign_key => "portlet_id",
                               :table_name => Namespacing.prefix("portlet_attributes"),
                               :relationship_name => :portlet_attributes

        acts_as_content_block(
            :versioned => false,
            :publishable => false,
            :renderable => {:instance_variable_name_for_view => "@portlet"})

        # Used to skip the 'after_save' callbacks that connect blocks to pages.
        # Portlets aren't verisonable but are connectable, so this will prevent the saving of portlets.
        attr_accessor :skip_callbacks


        def self.template_path
          default_template_path
        end

        def self.helper_path
          "app/portlets/helpers/#{name.underscore}_helper.rb"
        end

        def self.helper_class
          "#{name}Helper".constantize
        end
      end
    end

    def self.has_edit_link?
      false
    end

    def self.types
      @types ||= ActiveSupport::Dependencies.autoload_paths.map do |d|
        if d =~ /app\/portlets/
          Dir["#{d}/*_portlet.rb"].map do |p|
            File.basename(p, ".rb").classify
          end
        end
      end.flatten.compact.uniq.sort
    end

    def self.get_subclass(type)
      raise "Unknown Portlet Type" unless types.map(&:name).include?(type)
      type.constantize
    end

    # For column in list
    def portlet_type_name
      type.titleize
    end

    def self.form
      "portlets/#{name.tableize.sub('_portlets', '')}/form"
    end

    def self.default_template
      template_file = ActionController::Base.view_paths.map do |vp|
        path = vp.to_s.first == "/" ? vp.to_s : Rails.root.join(vp.to_s)
        Dir[File.join(path, default_template_path) + '.*']
      end.flatten.first
      template_file ? open(template_file) { |f| f.read } : ""
    end

    def self.set_default_template_path(s)
      @default_template_path = s
    end

    def self.default_template_path
      @default_template_path ||= "portlets/#{name.tableize.sub('_portlets', '')}/render"
    end

    # Called by 'render' to determine if this portlet should render itself using a file (render.html.erb) or using
    # its 'template' attribute.
    def inline_options
      options = {}
      options[:inline] = self.template if self.class.render_inline && !(self.template.nil? || self.template.blank?)
      options[:type] = self.handler unless self.handler.blank?
      options
    end

    def self.handler(handler_type)
      define_method(:handler) { handler_type }
    end

    # Determines if the template editor in the CMS UI will be enabled when creating or editing instances of this portlet
    # If enabled, the portlet will use the template code stored in the database. If not, it will render from the render.html.erb
    # file created.
    def self.enable_template_editor (enabled)
      render_inline enabled
    end

    def self.render_inline(*args)
      if args.length > 0
        @render_inline = args.first
      elsif !defined?(@render_inline)
        @render_inline = true
      else
        @render_inline
      end
    end

    def type_name
      type.to_s.titleize
    end

    def self.columns_for_index
      [{:label => "Name", :method => :name, :order => "name"},
       {:label => "Type", :method => :type_name, :order => "type"},
       {:label => "Updated On", :method => :updated_on_string, :order => "updated_at"}]
    end

    # Duck typing (like a ContentBlock) for determining if this block should have a usages link or not.
    def self.connectable?
      true
    end

    #----- Portlet Action Related Methods ----------------------------------------
    def instance_name
      "#{self.class.name.demodulize.underscore}_#{id}"
    end

    def url_for_success
      [params[:success_url], self.success_url, request.referer].detect do |e|
        !e.blank?
      end
    end

    def url_for_failure
      [params[:failure_url], self.failure_url, request.referer].detect do |e|
        !e.blank?
      end
    end

    # This will copy all the params from this request into the flash.
    # The key in the flash with be the portlet instance_name and
    # the value will be the hash of all the params, except the params
    # that have values that are a StringIO or a Tempfile will be left out.
    def store_params_in_flash
      store_hash_in_flash instance_name, params
    end

    # This will convert the errors object into a hash and then store it
    # in the flash under the key #{portlet.instance_name}_errors
    def store_errors_in_flash(errors)
      store_hash_in_flash("#{instance_name}_errors",
                          errors.inject({}) { |h, (k, v)| h[k] = v; h })
    end

    def store_hash_in_flash(key, hash)
      flash[key] = hash.inject(HashWithIndifferentAccess.new) do |p, (k, v)|
        unless StringIO === v || Tempfile === v
          p[k.to_sym] = v
        end
        p
      end
    end

  end
end