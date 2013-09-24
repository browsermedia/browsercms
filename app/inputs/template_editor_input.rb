class TemplateEditorInput < SimpleForm::Inputs::TextInput

  include Cms::FormBuilder::DefaultInput

  def label
    super if render_template_input?
  end

  def input
    if render_template_input?
      options[:default] = object.class.default_template
      options[:default_handler] = "erb" unless options[:default_handler]
      view = @builder.select "#{attribute_name}_handler", ActionView::Template.template_handler_extensions, selected: options[:default_handler]
      view << '<br />'.html_safe
      extract_default
      view << @builder.text_area(attribute_name, input_html_options).html_safe
    end
  end

  private
  def render_template_input?
    object.class.render_inline
  end
end