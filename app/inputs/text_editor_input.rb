class TextEditorInput < SimpleForm::Inputs::TextInput

  def input(wrapper_options = nil)
    tag_id = "#{object_name}_#{attribute_name}"
    path = input_html_options.fetch(:data, {})[:path]
    s = template.select_tag(:dhtml_selector,
                            template.options_for_select([["Rich Text", ""],["Simple Text", "disabled"]],
                                                        template.cookies["editorEnabled_#{tag_id}_#{path}"] == 'true' ? "" : "disabled"),
                            :class => "#{object_name}_#{attribute_name}_dhtml_selector",
                            :tabindex => '-1',
                            :onchange => "toggleEditor('#{tag_id}', this)".html_safe,
                            :data => input_html_options[:data])
    s += template.content_tag(:div, super, class: 'editor')

  end

  # Mark textarea with class for WYSIWYG editor.
  def input_html_classes
    super.push('editor')
  end
end
