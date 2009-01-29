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
  
end