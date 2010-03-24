class Cms::CategoriesController < Cms::ContentBlockController
  def show
    redirect_to cms_categories_url
  end
end
