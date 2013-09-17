# Displays a text field with a JQuery DatePicker widget.
#   1. Allows for empty dates (i.e. no date)
class DatePickerInput < SimpleForm::Inputs::TextInput

  def input
    @builder.text_field(attribute_name, input_html_options).html_safe
  end
end