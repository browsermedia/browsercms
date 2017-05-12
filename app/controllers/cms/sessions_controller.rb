module Cms
  # Handles the login/logout function of the site.
  class SessionsController < Devise::SessionsController
    include Cms::AdminController
    before_action :redirect_to_cms_site, :only => [:new]

    layout 'cms/application'

    def new
      use_page_title 'Login'
      super
    end

  end
end