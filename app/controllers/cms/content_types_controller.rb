require_dependency "cms/application_controller"

module Cms
  class ContentTypesController < ApplicationController

    def index
      content_type = ContentType.named(params[:content_type]).first
      @attributes = content_type.orderable_attributes.sort()
      respond_to do |format|
        format.js { render :layout => false }
      end
    end
  end
end
