module Cms
  class ProductsController < Cms::ContentBlockController

    skip_filter :cms_access_required, :login_required
    before_filter :cms_access_required, except: [:view]
    before_filter :login_required, except: [:view]



    def view_as_page
      @product = Product.where(slug: params[:slug]).first
      @page = @product
      render 'view', layout: "templates/default"
    end

  end
end
