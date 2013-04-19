module Cms
  class ProductsController < Cms::ContentBlockController

    skip_filter :cms_access_required, :login_required
    before_filter :cms_access_required, except: [:view]
    before_filter :login_required, except: [:view]
  end
end
