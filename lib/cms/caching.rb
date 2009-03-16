module Cms
  module Caching
    def flush_cache
      #Hmmm...this is kinda scary.  What if page cache directory is
      #set to the the default, which is /public?
      #So we are going to check that the directory is not called "public"
      if File.exists?(ActionController::Base.page_cache_directory) && 
          File.basename(ActionController::Base.page_cache_directory) != "public"
        FileUtils.rm_rf Dir.glob("#{ActionController::Base.page_cache_directory}/*")
      end
    end   
  end
  class << self
    include Caching
  end
end