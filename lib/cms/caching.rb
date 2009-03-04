module Cms
  # There are two caches used in the CMS.  First is called the public cache and is really just an alias for 
  # the default Rails cache.  The second is the protected cache, which contains files that can only be shown
  # to users with the proper authorization.
  module Caching
    def caching_enabled?
      @caching_enabled ||= (Rails.env == "production")
    end

    def caching_enabled=(caching_enabled)
      @caching_enabled = caching_enabled
    end

    # This is the cache of files that can be served directly to any user, guest or registered
    def public_cache
      ActionController::Base.cache_store
    end
    # This is the cache of files that can be served to a user provided they are authorized to see it
    def protected_cache
      ActiveSupport::Cache.lookup_store(:file_store, File.expand_path(File.join(Rails.root, "tmp/protected_cache")))
    end 
    # This will empty everything from both caches
    def flush_cache
      public_cache.flush
      protected_cache.flush
    end   
  end
  class << self
    include Caching
  end
end