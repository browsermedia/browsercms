class Cms::CacheController < Cms::BaseController
  layout 'cms/administration'
  
  check_permissions :administrate  
  before_filter :set_menu_section

  def show
    
  end
  
  def destroy
    Cms.flush_cache
    flash[:notice] = "Page Cache Flushed"
    redirect_to :action => "show"
  end
  
  private
    def set_menu_section
      @menu_section = 'caching'
    end

end
