# Adds additional attributes to text field.
class CmsTextFieldInput < SimpleForm::Inputs::TextInput

  include Cms::FormBuilder::DefaultInput

  # @todo Generating a slug probably shouldn't be done as a side effect of a :name field.
  def input

    if should_autogenerate_slug?(attribute_name)
      input_html_options[:class] << 'slug-source'
    end

    extract_default
    html = @builder.text_field(attribute_name, input_html_options).html_safe

    html
  end


  protected

  def should_autogenerate_slug?(method)
    content_requires_slug_field?(method) && (object.new_record? || (object.name.blank? && object.slug.blank?))
  end

  def content_requires_slug_field?(method)
    method == :name && object.class.requires_slug?
  end
end