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

    def request_is_for_cms_subdomain?
      cms_site?
    end

    def cms_site?
      subdomains = request.subdomains
      subdomains.shift if subdomains.first == "www"
      subdomains.first == cms_domain_prefix
    end

    # Determines if users should be redirected between the public (www.) and admin (cms.) subdomains.
    def using_cms_subdomains?
      result = (wants_to_use_subdomains? && perform_caching)
      #Rails.logger.debug {"Are we using cms subdomains? #{result} based on 'want subdomain: #{wants_to_use_subdomains?}' and perform_caching: '#{perform_caching}'"}
      result
    end

    def should_write_to_page_cache?
      using_cms_subdomains?
    end

    private

    def wants_to_use_subdomains?
      !Rails.configuration.cms.use_single_domain
    end

  end
end
