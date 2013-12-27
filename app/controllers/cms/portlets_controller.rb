module Cms
  class PortletsController < Cms::ContentBlockController

    before_action :apply_blacklist, only: [:new, :create]

    protected

    # Ensure we can't create portlets on the blacklist of types.
    # Existing instances can be edited/deleted.
    def apply_blacklist
       if params[:type] && Cms::Portlet.blacklisted?(params[:type].to_sym)
         render status: :method_not_allowed
       end
    end

    def build_block
      if params[:type].blank?
        @block = model_class.new
      else
        @block = params[:type].classify.constantize.new(params[:portlet])
      end

    end

    def update_block
      load_block
      @block.update(params[:portlet])
    end

    def block_form
      "portlets/portlets/form"
    end

  end
end