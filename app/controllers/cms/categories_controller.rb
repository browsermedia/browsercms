module Cms
class CategoriesController < Cms::ContentBlockController
  def show
    redirect_to cms_categories_url
  end
end
end