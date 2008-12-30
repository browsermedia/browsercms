class ContentObserver < ActiveRecord::Observer
  observe *ContentType.list + [:page, :section, :section_node]

  def after_create(record)
    Cms.flush_cache
  end

  def after_update(record)
    Cms.flush_cache
  end

  def after_destroy(record)
    Cms.flush_cache
  end

end