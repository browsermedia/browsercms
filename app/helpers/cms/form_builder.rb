class Cms::FormBuilder < ActionView::Helpers::FormBuilder
  def text_editor(method, options = {})
    opts = options.dup
    if opts[:class] && !(/editor/ === opts[:class])
      opts[:class] << " editor"
    else
      opts[:class] = "editor"
    end 
    id = opts[:id] || "#{@object_name}_#{method}"
    disabled = opts[:editor_disabled]    
    html = "<select class=\"dhtml_selector\" name=\"dhtml_selector\" onchange=\"setEditor('#{id}', this);\" tabindex=\"32767\"><option value=\"\"#{' selected="selected"' unless disabled}>DHTML Editor</option><option value=\"disabled\"#{' selected="selected"' if disabled}>Simple Text</option></select>\n"
    html << "<div class='editor'>\n"
    html << "\n"
    opts[:editor_disabled] = nil;
    html << text_area(method, opts)
    html << "\n</div>"
    html
  end  
  
  def date_picker(method, options={})
    text_field(method, {:size => 10, :class => "date_picker"}.merge(options))
  end
  
  def tag_list(options={})
    text_field(:tag_list, {:size => 50, :class => "tags_field"}.merge(options))
  end
  
end

