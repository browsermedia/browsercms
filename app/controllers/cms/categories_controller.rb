module Cms
  class CategoriesController < Cms::ContentBlockController
    def show
      redirect_to categories_path
    end
  end
end