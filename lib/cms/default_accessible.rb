module Cms
  module DefaultAccessible

    def self.included(model_class)
      model_class.attribute_names.each do |name|
        unless [:id, :type, :created_by_id, :updated_by_id, :created_at, :updated_at].include?(name.to_sym)
          model_class.attr_accessible name
        end
      end
    end

  end
end