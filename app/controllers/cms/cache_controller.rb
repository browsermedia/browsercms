module Cms
  class CacheController < Cms::BaseController

    include Cms::AdminTab
    check_permissions :administrate

    def show

    end

    def destroy
      Cms::Cache.flush
      flash[:notice] = "Page Cache Flushed"
      redirect_to :action => "show"
    end

    private
    def set_menu_section
      @menu_section = 'caching'
    end

  end
end