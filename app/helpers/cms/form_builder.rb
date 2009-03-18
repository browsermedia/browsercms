class Cms::FormBuilder < ActionView::Helpers::FormBuilder
  
  def cms_text_field(method, options={})
    add_tab_index!(options)
    cms_options = options.extract!(:label, :instructions)
    render_cms_form_partial :text_field, 
      :method => method, :options => options, :cms_options => cms_options
  end
  
  def text_editor(method, options = {})
    opts = options.dup
    if opts[:class] && !(/ editor / === opts[:class])
      opts[:class] << " editor"
    else
      opts[:class] = "editor"
    end 
    id = opts[:id] || "#{@object_name}_#{method}"
    enabled = cookies["editorEnabled"].blank? ? true : (cookies["editorEnabled"] == 'true' || cookies["editorEnabled"] == ['true'])
    html = <<-HTML
      <select class="dhtml_selector" name="dhtml_selector" onchange="toggleEditor('#{id}', this)">
        <option value=""#{ ' selected="selected"' if enabled }>Rich Text</option>
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
  
    def add_tab_index!(options)
      if options.has_key?(:tabindex)
        options.delete(:tabindex) if options[:tabindex].blank?
      else 
        options[:tabindex] = @template.next_tabindex
      end
    end
  
    def cookies
      #Ugly, is there an easier way to get to the cookies?
      @template.instance_variable_get("@_request").cookies || {}
    end
  
    def render_cms_form_partial(field_type_name, locals)
      @template.render :partial => "cms/form_builder/cms_#{field_type_name}",
        :locals => {:f => self}.merge(locals)
    end
  
end

