class Cms::ApplicationController < ApplicationController
  include Cms::Authentication::Controller
  include Cms::ErrorHandling

  helper :all # include all helpers, all the time

  helper Cms::ApplicationHelper
  include Cms::PathHelper
  helper Cms::PathHelper
  include Cms::PageHelper
  helper Cms::PageHelper
  helper Cms::MenuHelper
  
  def append_to_query_string(url, *params)
    new_url = url["?"] ? url : "#{url}?"
    new_url << params.map{|k,v| "#{k.to_s}=#{CGI::escape(v.to_s)}"}.join("&")
  end
  
  def self.check_permissions(*perms)
    opts = Hash === perms.last ? perms.pop : {}
    before_filter(opts) do |controller|
      raise Cms::Errors::AccessDenied unless controller.send(:current_user).able_to?(*perms)
    end      
  end  
  
  def cms_domain_prefix
    "cms"
  end
  
  def cms_site?
    subdomains = request.subdomains
    subdomains.shift if subdomains.first == "www"
    subdomains.first == cms_domain_prefix
  end
  
  def url_without_cms_domain_prefix
    request.url.sub(/#{cms_domain_prefix}\./,'')
  end
  
end