module Cms
  module Extensions
    module Hash
      #Returns a copy of the hash without the keys passed as arguments
      def except(*args)
        reject {|k,v| args.include?(k) }
      end
      
      # This takes a list of keys and returns a new hash 
      # containing the key/values that match the keys passed in. 
      # This will also remove the keys from this hash
      #
      # Note: This behavior is slightly different from ActiveSupport Hash#extract! which can add nil keys if they don't exist.
      def extract_only!(*keys)
        keys.inject({}) do |hash, key|
          hash[key] = delete(key) if has_key?(key)
          hash
        end
      end
    end
  end
end
Hash.send(:include, Cms::Extensions::Hash)