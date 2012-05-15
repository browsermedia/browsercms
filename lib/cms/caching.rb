module Cms
  module DefaultCaches
    # Returns the directory where BrowserCMS should write out it's Page cache files for the mobile version of the site.
    # (Optionally) It can be configured in environment files via:
    #   config.cms.mobile_cache_directory = File.join(Rails.root, 'some', 'mobile_dir')
    def mobile_cache_directory
      Rails.application.config.cms.mobile_cache_directory
    end

    # Returns the directory where BrowserCMS should write out it's Page cache files for the full version of the site.
    # This should be exactly the same as where a typical CMS project stores it's files.
    # (Optionally) It can be configured in environment files via:
    #   config.cms.page_cache_directory = File.join(Rails.root, 'some', 'dir')
    def cms_cache_directory
      Rails.application.config.cms.page_cache_directory
    end

  end

  module Caching
    include DefaultCaches
    # Determine if page caching in enabled.
    def caching_enabled?
      ActionController::Base.perform_caching
    end

    # Flushes page cache if caching has been enabled.
    def flush
      if caching_enabled?
        flush_caches
      end
    end

    private

    def flush_caches
      flush_cache_directory(cms_cache_directory)
      flush_cache_directory(mobile_cache_directory)
    end

    def flush_cache_directory(cache)
      if File.exists?(cache) && not_public_directory?(cache)
        FileUtils.rm_rf Dir.glob("#{cache}/*")
        Rails.logger.info "Flush cache in '#{cache}'"
      end
    end

    #Hmmm...this is kinda scary.  What if page cache directory is
    #set to the the default, which is /public?
    #So we are going to check that the directory is not called "public"
    def not_public_directory?(directory)
      File.basename(directory) != "public"
    end

  end

  class Cache
    class << self
      include Caching
    end
  end
end