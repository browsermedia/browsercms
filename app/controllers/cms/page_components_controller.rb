module Cms
  class PageComponentsController < Cms::ApplicationController

    respond_to :json

    def update
      @page_component = PageComponent.new(params[:id], params[:content])
      if @page_component.save
        respond_with(@page_component, :status => :success, :location => @page_component)
      else
        respond_with(@page_component.errors, :status => :unprocessable_entity)
      end
    end
  end
end