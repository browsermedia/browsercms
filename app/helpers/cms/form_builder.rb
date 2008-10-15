class Cms::FormBuilder < ActionView::Helpers::FormBuilder
  def text_editor(method, options = {})
    opts = options.dup
    if opts[:class] && !(/editor/ === opts[:class])
      opts[:class] << " editor"
    else
      opts[:class] = "editor"
    end 
    id = opts[:id] || "#{@object_name}_#{method}"
    html = "<div class='editor'>\n"
    html << @template.link_to_function("Toggle DHTML Editor", "toggleEditor('#{id}')", :class => "toggleEditor")
    html << "\n"
    html << text_area(method, opts)
    html << "\n</div>"
    html
  end  
end
