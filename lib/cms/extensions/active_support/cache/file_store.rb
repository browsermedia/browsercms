module ActiveSupport
  module Cache
    class FileStore
      def delete_all
        FileUtils.rm_rf cache_path
      end
    end
  end
end