module Cms
  class ProductsController < Cms::ContentBlockController

    skip_filter :cms_access_required, :login_required
    before_filter :cms_access_required, except: [:view]
    before_filter :login_required, except: [:view]

    before_filter :set_default_section, only: [:edit, :new]

    def view
      @product = Product.where(slug: params[:slug]).first
      @page = @product
      render layout: "templates/default"
    end

    def build_block
      super
      assign_to_section_if_specified()
    end

    def set_default_section
      @section = Section.with_path("/products").first
    end

    private

    def assign_to_section_if_specified
      @block.parent = Cms::Section.find(params[:section]) if params[:section]
    end
  end
end
