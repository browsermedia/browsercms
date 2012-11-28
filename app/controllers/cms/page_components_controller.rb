module Cms
  class PageComponentsController < Cms::ApplicationController
    layout false
    respond_to :json

    def new
      @default_type = Cms::ContentType.default
      @content_types = Cms::ContentType.other_connectables
    end

    def update
      @page_component = PageComponent.new(params[:id], params[:content])
      if @page_component.save
        respond_with(@page_component)
      else
        respond_with(@page_component.errors, :status => :unprocessable_entity)
      end
    end
  end
end