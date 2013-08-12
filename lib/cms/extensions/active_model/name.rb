module Cms
  module ActiveModel
    module Name

      # Provide backwards capablity with Rails 3.2.x method.
      # Hopefully only has_dynamic_attributes requires this.
      def foreign_key
        "#{self.param_key}_id"
      end
    end
  end
end
ActiveModel::Name.send(:include, Cms::ActiveModel::Name)