module Cms
  module DefaultAccessible

    def permitted_params
      attribute_names.map{|string| string.to_sym} - non_permitted_params
    end

    def non_permitted_params
      [:id, :type, :created_by_id, :updated_by_id, :created_at, :updated_at]
    end

  end
end