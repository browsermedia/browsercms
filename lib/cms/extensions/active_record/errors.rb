module Cms
  module Extensions
    module ActiveModel
      module Errors
        def add_from_hash(errors)
          errors.each{|k,v| add(k, v) } unless errors.blank?
        end
      end
    end
  end
end
ActiveModel::Errors.send(:include, Cms::Extensions::ActiveModel::Errors)
