class Cms::FormBuilder < ActionView::Helpers::FormBuilder
  def text_editor(method, options = {})
    opts = options.dup
    if opts[:class] && !(/ editor / === opts[:class])
      opts[:class] << " editor"
    else
      opts[:class] = "editor"
    end 
    id = opts[:id] || "#{@object_name}_#{method}"
    Rails.logger.info "cookies[\"editorEnabled\"] => #{cookies["editorEnabled"].inspect}"
    enabled = cookies["editorEnabled"].blank? ? true : (cookies["editorEnabled"] == 'true' || cookies["editorEnabled"] == ['true'])
    html = <<-HTML
      <select class="dhtml_selector" name="dhtml_selector" onchange="toggleEditor('#{id}', this)" tabindex="32767">
        <option value=""#{ ' selected="selected"' if enabled }>DHTML Editor</option>
        <option value="disabled"#{ ' selected="selected"' unless enabled }>Simple Text</option>
      </select>
      <div class="editor">
        #{text_area(method, opts)}
      </div>      
    HTML
  end  
  
  def date_picker(method, options={})
    text_field(method, {:size => 10, :class => "date_picker"}.merge(options))
  end
  
  def tag_list(options={})
    text_field(:tag_list, {:size => 50, :class => "tag-list"}.merge(options))
  end

  private
    def cookies
      #Ugly, is there an easier way to get to the cookies?
      @template.instance_variable_get("@_request").cookies || {}
    end
  
end

