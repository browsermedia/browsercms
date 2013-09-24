# Adds additional options to the TextArea
# @option [String] :default A default value
class CmsTextAreaInput < SimpleForm::Inputs::TextInput

  include Cms::FormBuilder::DefaultInput
  def input
    extract_default
    @builder.text_area(attribute_name, input_html_options).html_safe
  end
end