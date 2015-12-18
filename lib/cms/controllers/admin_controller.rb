module Cms

  # Before for any controller that is considered an admin page within BrowserCMS.
  module AdminController
    extend ActiveSupport::Concern

    included do
      include Cms::Authentication::Controller
      include Cms::ErrorHandling
      include Cms::DomainSupport

      helper Cms::ApplicationHelper
      helper Cms::FormTagHelper
      include Cms::PathHelper
      helper Cms::PathHelper
      include Cms::PageHelper
      helper Cms::PageHelper
      helper Cms::MenuHelper
      helper Cms::RenderingHelper
      helper Cms::UiElementsHelper
      include Cms::NavMenuHelper

    end

    protected
    def escape_javascript(javascript)
      (javascript || '').gsub('\\', '\0\0').gsub('</', '<\/').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
    end

    def redirect_to_first(*urls)
      urls.each do |url|
        unless url.blank?
          return redirect_to(url)
        end
      end
    end

    def current_site
      @current_site ||= Site.find_by_domain(request.host)
    end

    def redirect_to_cms_site
      if using_cms_subdomains? && !request_is_for_cms_subdomain?
        redirect_to(url_with_cms_domain_prefix)
      end
    end

    def append_to_query_string(url, *params)
      new_url = url["?"] ? url : "#{url}?"
      new_url << params.map { |k, v| "#{k.to_s}=#{CGI::escape(v.to_s)}" }.join("&")
    end

    def cms_access_required
      raise Cms::Errors::AccessDenied unless current_cms_user.able_to?(:administrate, :edit_content, :publish_content)
    end

    def url_with_cms_domain_prefix
      if cms_site?
        request.url
      elsif request.subdomains.first == "www"
        request.url.sub(/www\./, "#{cms_domain_prefix}.")
      else
        request.url.sub(/:\/\//, "://#{cms_domain_prefix}.")
      end
    end

    def url_without_cms_domain_prefix
      request.url.sub(/#{cms_domain_prefix}\./, '')
    end

    def ensure_current_cms_user_can_view(content)
      unless current_cms_user.able_to_view?(content)
        store_location
        raise Cms::Errors::AccessDenied
      end
    end
  end
end