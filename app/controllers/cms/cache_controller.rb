class Cms::CacheController < Cms::BaseController
  layout 'cms/administration'
  
  verify :method => :post, :only => :expire
  
  def expire
    ActionController::Base.cache_store.delete_all
    flash[:notice] = "Page Cache Flushed"
    redirect_to :action => "index"
  end
  
end