class Cms::BaseController < Cms::ApplicationController
  
  before_filter :redirect_to_cms_site
  before_filter :login_required
  before_filter :cms_access_required
  
  before_filter :set_locale if Rails.env.development?

  layout 'cms/application'
    
  verify :method => :post, :only => [:create]
  verify :method => :put, :only => [:update]
  verify :method => :delete, :only => [:destroy]
  
  
  private
  def set_locale
    I18n.locale = cookies[:locale]
  end
    
end