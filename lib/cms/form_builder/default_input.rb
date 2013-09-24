module Cms
  module FormBuilder
    module DefaultInput

      # Use a default value if there isn't one specfied already.
      def extract_default
        if options[:default] && object.new_record? && object.send(attribute_name).blank?
          input_html_options[:value] = options[:default]
        end
      end
    end
  end
end