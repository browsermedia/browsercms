module Cms
  module FormBuilder
    # These FormBuilder inputs are deprecated as of BrowserCMS v4.0 and will be remove in 4.1.
    module DeprecatedInputs

      # @deprecated Use <%= f.input :attribute_name %> instead.
      def cms_text_field(method, options={})
        method_deprecated_use_instead(:cms_text_field, "<%= f.input :#{method} %>")
        input method, options
      end

      def cms_text_editor(method, options={})
        method_deprecated_use_instead(:cms_text_editor, "<%= f.input :#{method}, as: :text_editor %>")
        input method, options.merge(as: :text_editor)
      end

      def template_editor(method, options={})
        method_deprecated_use_instead(:template_editor, "<%= f.input :#{method}, as: :template_editor %>")
        input method, options.merge(as: :template_editor)
      end

      def cms_file_field(method, options={})
        method_deprecated_use_instead(:cms_file_field, "<%= f.input :#{method}, as: :file_picker %>")
        input method, options.merge(as: :file_picker)
      end

      def cms_drop_down(method, collection, options={})
        method_deprecated_use_instead(:cms_drop_down, "<%= f.association :association_name %>")
        input method, options.merge(collection: collection)
      end

      protected

      def method_deprecated_use_instead(original, alternative)
        full_message = "Calling <%= f.#{original.to_s} %> is deprecated and will be removed in BrowserCMS 4.1. Try instead #{alternative}"
        ActiveSupport::Deprecation.warn(full_message, caller(3))
      end
    end
  end
end