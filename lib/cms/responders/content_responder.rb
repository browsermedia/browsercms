module Cms
  class ContentResponder < ActionController::Responder

    def initialize(controller, resources, options={})
      @page = resources[0]
      @page_layout = resources[1]
      super(controller, resources, options)
    end

    def to_html
      render :layout => @page_layout, :action => 'show'
    end
  end
end
