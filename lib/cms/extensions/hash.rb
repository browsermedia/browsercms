module Cms
  module Extensions
    module Hash
      #Returns a copy of the hash without the keys passed as arguments
      def except(*args)
        reject {|k,v| args.include?(k) }
      end
    end
  end
end
Hash.send(:include, Cms::Extensions::Hash)