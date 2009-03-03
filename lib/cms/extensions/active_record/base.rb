module Cms
  module Extensions
    module ActiveRecord
      module Base
        def updated_on_string(fmt="%b %e, %Y")
          if respond_to?(:updated_at) && updated_at
            updated_at.strftime(fmt).gsub(/\s{2,}/," ")
          else
            nil
          end
        end
      end
    end
  end
end
ActiveRecord::Base.send(:include, Cms::Extensions::ActiveRecord::Base)