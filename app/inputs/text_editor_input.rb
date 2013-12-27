class TextEditorInput < SimpleForm::Inputs::TextInput

  def input
    tag_id = "#{object_name}_#{attribute_name}"
    s = template.select_tag(:dhtml_selector,
                                  template.options_for_select([["Rich Text", ""],["Simple Text", "disabled"]],
                                  template.cookies[:editorEnabled] == 'true' ? "" : "disabled"),
                                  :class => "#{object_name}_#{attribute_name}_dhtml_selector",
                                  :tabindex => '-1',
                                  :onchange => "toggleEditor('#{tag_id}', this)".html_safe)
    s += template.content_tag(:div, super, class: 'editor')

  end

  # Mark textarea with class for WYSIWYG editor.
  def input_html_classes
    super.push('editor')
  end
end