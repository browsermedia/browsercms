module Cms
  class ContentTypesController < Cms::BaseController

    def index
      @content_types = ContentType.order(:name)
    end

  end
end