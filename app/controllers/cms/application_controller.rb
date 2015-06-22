module Cms
  class ApplicationController < ::ApplicationController
    include Cms::AdminController
    
    before_action :no_browser_caching
    
    def no_browser_caching
      expires_now
    end
  end
end