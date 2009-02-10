class Cms::BaseController < Cms::ApplicationController
  
  before_filter :login_required
  after_filter :clear_current_user
  layout 'cms/application'
    
  verify :method => :post, :only => [:create]
  verify :method => :put, :only => [:update]
  verify :method => :delete, :only => [:destroy]
    
  protected
    def escape_javascript(javascript)
      (javascript || '').gsub('\\','\0\0').gsub('</','<\/').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
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
   
    def self.check_permissions(*perms)
      opts = Hash === perms.last ? perms.pop : {}
      before_filter(opts) do |controller|
        raise Cms::Errors::AccessDenied unless controller.send(:current_user).able_to?(*perms)
      end      
    end
    
    def clear_current_user
      User.current = nil
    end

  public
  
  check_permissions :administrate, :publish_content, :edit_content, :except => [:login, :logout]
    
end