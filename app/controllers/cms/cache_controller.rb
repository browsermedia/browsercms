class Cms::CacheController < Cms::BaseController
  layout 'cms/administration'
  check_permissions :administrate  
  before_filter :set_menu_section
  verify :method => :post, :only => :expire

  def index
    
  end
  
  def expire
    Cms.flush_cache
    flash[:notice] = "Page Cache Flushed"
    redirect_to :action => "index"
  end
  
  private
    def set_menu_section
      @menu_section = 'caching'
    end

end
