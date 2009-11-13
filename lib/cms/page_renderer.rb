# A support module for pages that need to render pages.
module Cms
  module PageRenderer

    protected

    def cms_domain_prefix
      "cms"
    end

    def cms_site?
      subdomains = request.subdomains
      subdomains.shift if subdomains.first == "www"
      subdomains.first == cms_domain_prefix
    end
  end
end
