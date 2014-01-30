# A text field that is used for the Name fields of content.
#
# @example <%= f.name as: :name %>
#
# Add the following behaviors above and beyond
#   1. Will generate a slug if the class requires it. (Requires a as: :path field to work)
#   2. If no label is specified, it shows a larger than normal input which spans the full row.
#   3. Labels are turned off by default.
class NameInput < SimpleForm::Inputs::TextInput

  def initialize(*args)
    super(*args)
    options[:label] = false if options[:label].nil?
    options[:placeholder] = "Name" if options[:placeholder].nil?
  end

  def input
    add_slug_source_for_content_that_needs_it

    unless options[:label]
      input_html_options[:class] << 'input-block-level input-xxlarge'
    end

    @builder.text_field(attribute_name, input_html_options).html_safe
  end

  protected

  def add_slug_source_for_content_that_needs_it
    if should_autogenerate_slug?
      input_html_options[:class] << 'slug-source'
    end
  end

  def should_autogenerate_slug?
    content_requires_slug_field? && (object.new_record? || (object.name.blank? && object.slug.blank?))
  end

  def content_requires_slug_field?
    object.class.requires_slug?
  end
end