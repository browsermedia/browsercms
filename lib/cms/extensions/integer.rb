module Cms
  module Extensions
    module Integer
      def round_bytes
        if self > 1.megabyte
          "%0.2f MB" % (self.to_f/1.megabyte)
        elsif self > 1.kilobyte
          "%0.2f KB" % (self.to_f/1.kilobyte)
        else
          "#{self} bytes"
        end
      end
    end
  end
end
Integer.send(:include, Cms::Extensions::Integer)