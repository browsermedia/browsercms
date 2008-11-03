class ContentObserver < ActiveRecord::Observer
  observe *ContentType.list + [:page, :section, :section_node]

  def after_create(record)
    expire_cache
  end

  def after_update(record)
    expire_cache
  end

  def after_destroy(record)
    expire_cache
  end
  
  private
  
  def expire_cache
    ActionController::Base.cache_store.delete_all
  end

end