module Cms
  module Caching
    def caching_enabled?
      ActionController::Base.perform_caching
    end
    def flush_cache
      #Hmmm...this is kinda scary.  What if page cache directory is
      #set to the the default, which is /public?
      #So we are going to check that the directory is not called "public"
      if File.exists?(ActionController::Base.page_cache_directory) && 
          File.basename(ActionController::Base.page_cache_directory) != "public"
        FileUtils.rm_rf Dir.glob("#{ActionController::Base.page_cache_directory}/*")
        Rails.logger.info "Cache Flushed"
      end
    end   
  end
  class << self
    include Caching
  end
end