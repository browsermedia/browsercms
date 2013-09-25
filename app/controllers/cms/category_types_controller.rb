module Cms
  class CategoryTypesController < Cms::ContentBlockController
    def show
      redirect_to edit_category_type_path(id: params[:id])
    end

    def create
      params[:_redirect_to] = category_types_path
      super
    end
  end
end