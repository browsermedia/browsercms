module Cms
  class CategoryTypesController < Cms::ContentBlockController
    def show
      redirect_to category_types_path
    end
  end
end