module ActiveSupport
  module Cache
    class FileStore
      def flush
        FileUtils.rm_rf cache_path if File.exist?(cache_path)
      end
    end
  end
end