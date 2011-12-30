module Cms
class PortletsController < Cms::ContentBlockController
  
  protected
    def load_blocks
      @blocks = Portlet.search(params[:search]).paginate(
        :page => params[:page],
        :order => params[:order] || "name",
        :conditions => ["deleted = ?", false]
      )
    end
  
    def build_block
      if params[:type].blank?
        @block = model_class.new
      else
        @block = params[:type].classify.constantize.new(params[params[:type]])
      end
    end
    
    def update_block
      load_block
      @block.update_attributes(params[@block.class.name.underscore])
    end    
    
    def block_form
      "portlets/portlets/form"
    end
    
    def new_block_path(block)
      new_portlet_path
    end
  
    def block_path(block, action=nil)
      send("#{action ? "#{action}_" : ""}portlet_path", block)
    end

    def blocks_path
      portlets_path
    end
end
end