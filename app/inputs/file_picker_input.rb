class FilePickerInput < SimpleForm::Inputs::Base

  def input
    string = @builder.file_field(attribute_name, input_html_options)
  end

end