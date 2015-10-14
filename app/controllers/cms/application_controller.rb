module Cms
  class ApplicationController < ::ApplicationController
    include Cms::AdminController

    unless Cms.allow_guests?
      before_filter :redirect_to_cms_site
      before_action :authenticate_cms_user!
      before_filter :cms_access_required
    end

    before_action :no_browser_caching
    
    def no_browser_caching
      expires_now
    end
  end
end