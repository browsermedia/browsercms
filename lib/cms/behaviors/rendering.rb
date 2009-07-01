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
    # One gotcha to be aware of with this behavior
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
        "app/helpers/cms/#{name.underscore}_helper.rb"
      end
  
      def helper_class
        "Cms::#{name}Helper".constantize
      end
  
      # This is where the path to the template. The default is based on the class
      # of the renderable, so if you have an Article that is renderable, 
      # the template will be "articles/render"
      def template_path
        "cms/#{name.underscore.pluralize}/render"
      end
  
      # Instance variables that will not be copied from the renderable to the view
      def ivars_to_ignore
        ['@controller', '@_already_rendered']
      end    
  
    end
    module InstanceMethods
      def perform_render(controller)
        # Give this renderable a reference to the controller
        @controller = controller

        copy_instance_variables_from_controller!

        # This gives the view a reference to this object
        instance_variable_set(self.class.instance_variable_name_for_view, self)

        # This is like a controller action
        # We will call it if you have defined a render method
        # but if you haven't we won't
        render if respond_to?(:render)
    
        # Create, Instantiate and Initialize the view
        view_class  = Class.new(ActionView::Base)      
        action_view = view_class.new(@controller.view_paths, {}, @controller)
    
        # Make helpers and instance vars available
        view_class.send(:include, @controller.class.master_helper_module)
        if $:.detect{|d| File.exists?(File.join(d, self.class.helper_path))}
          view_class.send(:include, self.class.helper_class)
        end
        
        # We want content_for to be called on the controller's view, not this inner view
        def action_view.content_for(name, content=nil, &block)
          controller.instance_variable_get("@template").content_for(name, content, &block)
        end
        
        # Copy instance variables from this renderable object to it's view
        action_view.assigns = assigns_for_view
          
        if respond_to?(:inline_options) && self.inline_options && self.inline_options.has_key?(:inline)
          options = {:locals => {}}.merge(self.inline_options)
          ActionView::InlineTemplate.new(options[:inline], options[:type]).render(action_view, options[:locals])
        else
          action_view.render(:file => self.class.template_path)
        end
      end
  
      protected
        def copy_instance_variables_from_controller!
          if @controller.respond_to?(:instance_variables_for_rendering)
            @controller.instance_variables_for_rendering.each do |iv|
              #logger.info "Copying #{iv} => #{@controller.instance_variable_get(iv).inspect}"
              instance_variable_set(iv, @controller.instance_variable_get(iv))
            end
          end
        end
      
        def assigns_for_view
          (instance_variables - self.class.ivars_to_ignore).inject({}) do |h,k|
            h[k[1..-1]] = instance_variable_get(k)
            h
          end
        end
      
    end
  end
end