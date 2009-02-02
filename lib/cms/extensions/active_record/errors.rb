module Cms
  module Extensions
    module ActiveRecord
      module Errors
        def add_from_hash(errors)
          errors.each{|k,v| add(k, v) } unless errors.blank?
        end
      end
    end
  end
end
ActiveRecord::Errors.send(:include, Cms::Extensions::ActiveRecord::Errors)
