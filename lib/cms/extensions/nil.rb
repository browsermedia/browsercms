module Cms
  module Extensions 
    module NilClass
      def round_bytes
        to_i.round_bytes
      end
      def markdown
        nil
      end
      def to_slug
        to_s
      end
      def to_formatted_s(format=nil)
        nil
      end
    end
  end
end
NilClass.send(:include, Cms::Extensions::NilClass)