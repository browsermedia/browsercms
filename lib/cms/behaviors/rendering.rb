module Cms
  module Behaviors
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
        
        # We want content_for to be called on the controller's view, not this inner view
        def action_view.content_for(name, content=nil, &block)
          controller.instance_variable_get("@template").content_for(name, content, &block)
        end
        
        # Copy instance variables from this renderable object to it's view
        action_view.assigns = assigns_for_view
          
        if respond_to?(:inline_options)
          options = {:locals => {}}.merge(self.inline_options)
          ActionView::InlineTemplate.new(options[:inline], options[:type]).render(action_view, options[:locals])
        else
          action_view.render(:file => self.class.template_path)
        end
      end
  
      protected
        def assigns_for_view
          (instance_variables - self.class.ivars_to_ignore).inject({}) do |h,k|
            h[k[1..-1]] = instance_variable_get(k)
            h
          end
        end
      
    end
  end
end