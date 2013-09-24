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

      def cms_error_messages
        return unless object.respond_to?(:errors) && object.errors.any?

        errors_list = ""
        errors_list << @template.content_tag(:h2, "#{object.errors.size} error prohibited this #{object_name.humanize} from being saved.".html_safe)
        errors_list << @template.content_tag(:p, "There were problems with the following fields:")
        errors_list << @template.content_tag(:ul, object.errors.full_messages.map { |message| @template.content_tag(:li, message).html_safe }.join("\n").html_safe).html_safe

        @template.content_tag(:div, errors_list.html_safe, :class => "errorExplanation", :id => "errorExplanation")
      end
    end
  end
end