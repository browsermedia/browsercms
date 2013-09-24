class PathInput < SimpleForm::Inputs::TextInput

  def input
    if forecasting_a_new_section?
      options[:hint] = "Forecast: Saving this first #{object.class.display_name} will create a new section at #{object.class.path}."
    end
    html = template.content_tag(:span, object.class.base_path, data:{type: 'base-path'})
    html << @builder.text_field(:slug, class: ['input-xxlarge', 'slug-dest'])
    html
  end

  protected

  def forecasting_a_new_section?
    Cms::Section.with_path(object.class.path).first.nil?
  end

end