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
    end
  end
end