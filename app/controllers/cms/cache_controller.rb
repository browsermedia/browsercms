class Cms::CacheController < Cms::BaseController
  layout 'cms/administration'
  check_permissions :administrate  
  verify :method => :post, :only => :expire
  
  def expire
    Cms.flush_cache
    flash[:notice] = "Page Cache Flushed"
    redirect_to :action => "index"
  end
  
end