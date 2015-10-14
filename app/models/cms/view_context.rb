module Cms

  # Trying to get rendering working:
  #
  # Things that need to happen:
  # 1. Need to add all helpers from that the Cms::ContentController has access to:
  # 2. Add helpers for the portlet or content block
  #
  # Understanding how Cms::ContentController renders a template:
  # 1. It starts with a layout, which is a CMS template.
  # 2. show.html.erb is called, which iterates over the connectables, adding content_for for each of the yields.
  #
  # TODOS
  # There are currently way to many values getting copied into this view, including:
  #   content_block (desired) - From ContentController
  #   content - An attribute of the block itself.
  class ViewContext < ActionView::Base

    # @param [ActionController::Base] controller The CMS controller rendering the overall page
    # @param [Hash] attributes_to_assign All the values that should be passed to this View as @attributes available.
    def initialize(controller, attributes_to_assign)
      @controller = controller
      super(@controller.view_paths, attributes_to_assign, @controller)


      helpers = controller.class._helpers
      self.class.send(:include, helpers)

      # Make all Route helpers available in the view, i.e. cms_xyz_path and cms_xyz_url
      self.class.send(:include, Cms::Engine.routes.url_helpers)

      # Need to add Cms::PageRoute helpers to the view
      self.class.send(:include, Rails.application.routes.url_helpers)

      # See what values are getting copied into template
      # Rails.logger.warn "Assigned these variables: #{attributes_to_assign}"

      # add mounted helpers if present
      @_mounted_helpers = Rails.application.routes.try(:mounted_helpers)
      self.class.include @_mounted_helpers if @_mounted_helpers
    end

    def method_missing(method, *args, &block)
      # default url options from App routes
      return Rails.application.routes.default_url_options if method == :default_url_options

      # try mounted helpers (note: we prefer mounted helper than routes.url_helpers)
      mounted_helper_method = "_#{method}"
      if @_mounted_helpers && respond_to?(mounted_helper_method)
        return send(mounted_helper_method, *args, &block)
      end

      # try loading engine (ie: cms => Cms::Engine, my_example => MyExample::Engine)
      engine = engine_by_method_name(method)
      return engine.routes.url_helpers if engine

      super
    end

    def engine_by_method_name(method)
      "#{method.to_s.camelcase}::Engine".constantize
    rescue NameError
      nil
    end

    # We want content_for to be called on the controller's view, not this inner view
    def content_for(name, content=nil, &block)
      Rails.logger.warn "content_for(#{name}, #{content}, block) called."

      template = @controller && @controller.instance_variable_get("@template")
      if template
        template.content_for(name, content, &block)
      else
        Rails.logger.warn "@template inside of @controller is nil. Controller: #{@controller.class}"
        super
      end
    end
  end


end
