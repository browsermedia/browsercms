#
# A support module for handling detecting if a page or controller is being
# served by the public or cms domain.
#
module Cms
  module DomainSupport

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
