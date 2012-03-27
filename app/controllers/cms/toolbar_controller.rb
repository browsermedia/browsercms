module Cms
  class ToolbarController < Cms::BaseController

    layout "cms/toolbar"

    helper MobileHelper

    def index
      if params[:page_toolbar] != "0"
        @mode = params[:mode]
        @page_toolbar_enabled = true
      end
      @page_version = params[:page_version]
      @page = Page.find(params[:page_id]).as_of_version(params[:page_version]) if params[:page_id]
    end

  end
end