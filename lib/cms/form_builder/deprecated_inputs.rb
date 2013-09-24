module Cms
  module FormBuilder
    # These FormBuilder inputs are deprecated as of BrowserCMS v4.0 and will be remove in 4.1.
    module DeprecatedInputs

      # @deprecated Use <%= f.input :attribute_name %> instead.
      def cms_text_field(method, options={})
        input method, options
      end

      def cms_text_editor(method, options={})
        input method, options.merge(as: :text_editor)
      end

      def template_editor(method, options={})
        input method, options.merge(as: :template_editor)
      end

      def cms_file_field(method, options={})
        input method, options.merge(as: :file_picker)
      end

      def cms_drop_down(method, collection, options={})
        input method, options.merge(collection: collection)
      end
    end
  end
end