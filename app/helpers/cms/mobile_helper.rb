module Cms
  module MobileHelper

    def full_site_url
      main_app.url_for(:host => Rails.configuration.cms.site_domain, :prefer_full_site => true)
    end

    def mobile_site_url
      main_app.url_for(:host => Rails.configuration.cms.site_domain, :prefer_mobile_site => true)
    end

    # Determines if the mobile template exists for a given page.
    # Used by view to show/hide the mobile toggle.
    def mobile_template_exists?(page)
      controller.template_exists?(page.layout_name, "layouts/mobile")
    end
  end

end