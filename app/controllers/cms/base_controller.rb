class Cms::BaseController < ApplicationController
  before_filter :login_required
  layout 'cms/application'
  
  
  protected
    def redirect_to_first(*urls)
      urls.each do |url|
        unless url.blank?
          return redirect_to(url)
        end
      end
    end
end