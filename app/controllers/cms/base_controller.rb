module Cms
  class BaseController < Cms::ApplicationController

    before_filter :redirect_to_cms_site
    before_action :authenticate_cms_user!
    before_filter :cms_access_required

    layout 'cms/application'


    # Disables the default security level for actions, meaning they will be available for guests to access.
    # Users will not need to login prior to accessing these methods.
    #
    # @param [Array<Symbol>] methods List of methods to disable security for.
    def self.allow_guests_to(methods)
      skip_before_action :redirect_to_cms_site, only: methods
      skip_before_action :authenticate_cms_user!, only: methods
      skip_before_action :cms_access_required, only: methods
    end

  end
end