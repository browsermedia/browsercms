class Cms::CategoryTypesController < Cms::ContentBlockController
  def show
    redirect_to cms_category_types_url
  end
end