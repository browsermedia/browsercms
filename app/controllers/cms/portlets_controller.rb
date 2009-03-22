class Cms::PortletsController < Cms::ContentBlockController
  
  protected
    def build_block
      if params[:type].blank?
        @block = model_class.new
      else
        @block = params[:type].classify.constantize.new(params[params[:type]])
      end
    end
    
    def block_form
      "portlets/portlets/form"
    end
    
    def new_block_path
      new_cms_portlet_path
    end
  
    def block_path(action=nil)
      send("#{action ? "#{action}_" : ""}cms_portlet_path", @block)
    end

    def blocks_path
      cms_portlets_path
    end
end