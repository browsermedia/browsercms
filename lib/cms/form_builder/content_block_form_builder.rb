require 'cms/form_builder/deprecated_inputs'

module Cms
  module FormBuilder
    # Adds additional methods to the forms for creating content blocks.
    class ContentBlockFormBuilder < SimpleForm::FormBuilder
      include DeprecatedInputs

      # Allows editors to add multiple files uploader for attachments.
      # Usage:
      #   <%= f.attachment_manager %>
      #
      # Generator: The following will generate an attachments field with an associated attachment manager input.
      #   rails generate cms:content_block Widget photos:attachments
      def cms_attachment_manager
        input :attachments, as: :attachments
      end

      # Allows editors add a space separated list of tags. Each tag entered will be created if needed as an instance of a Cms::Tag.
      #
      # Usage:
      #   <%= f.cms_tag_list %>
      #
      # There is no generator for this field type.
      #
      def cms_tag_list(options={})
        input :tag_list, as: :tag_list, label: "Tags", input_html: {autocomplete: 'off'}, hint: "A space separated list of tags."
      end

      # Displays a concise list of error messages. This is may be unnecessary given that simple form will display error inline.
      # Handles 'global' messages that aren't specific to a field.
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