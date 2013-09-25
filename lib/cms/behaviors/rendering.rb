module Cms
  module Behaviors
    # The Rendering Behavior allows a model to be rendered within a view.
    # The key methods are the instance methods perform_render, render and 
    # inline_options.  From within a view or a helper, you can render a
    # renderable object by calling the perform_render and passing the controller
    # object to it.
    #
    # When perform_render is called, it will first call the render instance method
    # of the renderable object.  This is very similar to a controller action.
    # The purpose of this method is to setup instance varaibles to be used by the
    # renderable's view.
    #
    # After the render method is called, it checks to see if there is a inline_options
    # instance method on the renderable object.  If so, it calls this and it expects
    # this to return a Hash that will be passed to render.  This expects there to be
    # an inline option, so this is the way to do inline rendering.
    #
    # Assuming there is no inline_options method, it will look for a template in the 
    # view path at cms/pluralized_class_name/render.  So if the Renderable class is
    # Article, the template should be at cms/articles/render.  It uses the same
    # format and template engine options as regular views, to the file name should
    # be render.html.erb.
    #
    module Rendering
      def self.included(model)
        model.extend(MacroMethods)
      end

      module MacroMethods
        def renderable?
          false
        end

        def is_renderable(options={})

          @instance_variable_name_for_view = options[:instance_variable_name_for_view]

          extend ClassMethods
          include InstanceMethods

          # I'm not pleased with the need to include all of the these rails helpers onto every 'renderable' content item
          # It's likely to lead to unfortunate side effects.
          # Need to determine how this can be simplified.

          # Required to make the calls to add Rails Core controllers work
          include ActiveSupport::Configurable

          # Include all the core rails helpers
          include ActionController::Helpers
          include ActionController::RequestForgeryProtection

          helper ApplicationHelper

          attr_accessor :controller
          delegate :params, :session, :request, :flash, :to => :controller

        end
      end
    end
    module ClassMethods
      def renderable?
        true
      end

      # This will be the used as the name of instance variable 
      # that will be available in the view.  The default value is "@renderable"
      def instance_variable_name_for_view
        @instance_variable_name_for_view ||= "@renderable"
      end

      def helper_path
        "app/helpers/#{name.underscore}_helper.rb"
      end

      def helper_class
        "Cms::#{name}Helper".constantize
      end

      # This is where the path to the template. The default is based on the class
      # of the renderable, so if you have an Article that is renderable, 
      # the template will be "articles/render"
      def template_path
        "#{name.underscore.pluralize}/render"
      end

      # Instance variables that will not be copied from the renderable to the view
      def ivars_to_ignore
        ['@controller', '@_already_rendered']
      end

    end
    module InstanceMethods

      # Returns the Mercury editor type for a given attribute
      # @param [Symbol] method (i.e. :name, :content, etc)
      # @return [Hash]
      def editor_info(method)
        column = self.class.columns_hash[method.to_s]
        if column.type == :text
          {:element => 'div', :region => 'full'}
        else
          {:element => 'span', :region => 'simple'}
        end
      end

      def prepare_to_render(controller)
        # Give this renderable a reference to the controller
        @controller = controller

        copy_instance_variables_from_controller!

        # This gives the view a reference to this object
        instance_variable_set(self.class.instance_variable_name_for_view, self)

        # This is like a controller action
        # We will call it if you have defined a render method
        # but if you haven't we won't
        render if should_render_self?
      end

      def perform_render(controller)
        return "Exception: #{@render_exception}" if @render_exception


        unless @controller
          # We haven't prepared to render. This should only happen when logged in, as we don't want
          # errors to bubble up and prevent the page being edited in that case.
          prepare_to_render(controller)
        end

        if self.respond_to?(:deleted) && self.deleted
          logger.error "Attempting to render deleted object: #{self.inspect}"
          msg = (edit_mode? ? %Q[<div class="error">This #{self.class.name} has been deleted.  Please remove this container from the page</div>] : '')
          return msg
        end

        # Create, Instantiate and Initialize the view
        action_view = Cms::ViewContext.new(@controller, assigns_for_view)

        add_content_helpers_if_defined(action_view)

        # Determine if this content should render from a file system template or inline (i.e. database based template)
        if respond_to?(:inline_options) && self.inline_options && self.inline_options.has_key?(:inline)
          options = self.inline_options
          locals = {}
          action_view.render(options, locals)
        else
          action_view.render(:file => self.class.template_path)
        end
      end

      def render_exception=(exception)
        @render_exception = exception
      end

      # Determines if a block should have its 'render' method called when it's rendered within a page.
      def should_render_self?
        # Reason to exist: This was added to work around the fact that Rails 3 AbstractController::Helpers defines its own
        # render method, which was conflicted with block's render methods.
        public_methods(false).include?(:render)
      end

      protected

      # Add the helper class for this particular object, if its defined
      # This is mostly for portlets, and should not fail if no helper is defined.
      def add_content_helpers_if_defined(action_view)
        begin
          helper_module = self.class.helper_class
          action_view.extend(helper_module)
        rescue NameError => error
          logger.debug "No helper class named '#{error.missing_name}' was found. This isn't necessarily an error as '#{self.class}' doesn't NEED a separate helper.'"
        end
      end

      def copy_instance_variables_from_controller!
        if @controller.respond_to?(:instance_variables_for_rendering)
          @controller.instance_variables_for_rendering.each do |iv|
            #logger.info "Copying #{iv} => #{@controller.instance_variable_get(iv).inspect}"
            instance_variable_set(iv, @controller.instance_variable_get(iv))
          end
        end
      end

      def assigns_for_view
        (instance_variables - self.class.ivars_to_ignore).inject({}) do |h, k|
          h[k[1..-1]] = instance_variable_get(k)
          h
        end
      end

    end
  end
end
