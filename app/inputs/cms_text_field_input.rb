# Adds additional attributes to text field.
class CmsTextFieldInput < SimpleForm::Inputs::TextInput

  include Cms::Inputs::DefaultInput

  def input
    extract_default
    @builder.text_field(attribute_name, input_html_options).html_safe
  end
end