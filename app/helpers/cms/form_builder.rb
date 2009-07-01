class Cms::FormBuilder < ActionView::Helpers::FormBuilder
  
  # These are the new fields we are adding
  
  # A JavaScript/CSS styled select
  def drop_down(method, choices, options = {}, html_options = {})
    @template.drop_down(@object_name, method, choices, objectify_options(options), add_tabindex!(@default_options.merge(html_options)))
  end

  def text_editor(method, options = {})
    @template.send(
      "text_editor",
      @object_name,
      method,
      objectify_options(options))
  end

  def date_picker(method, options={})
    text_field(method, {:size => 10, :class => "date_picker"}.merge(options))
  end
  
  def tag_list(options={})
    field_name = options.delete(:name) || :tag_list
    text_field(field_name, {:size => 50, :class => "tag-list"}.merge(options))
  end

  # These are the higher-level fields, 
  # that get wrapped in divs with labels, instructions, etc.
  
  %w[date_picker datetime_select text_area text_field file_field].each do |f|
    src = <<-end_src
      def cms_#{f}(method, options={})
        add_tabindex!(options)
        set_default_value!(method, options)
        cms_options = options.extract!(:label, :instructions, :default_value)
        render_cms_form_partial :#{f},
          :object_name => @object_name, :method => method,
          :options => options, :cms_options => cms_options
      end
    end_src
    class_eval src, __FILE__, __LINE__
  end
  
  def cms_drop_down(method, choices, options={}, html_options={})
    add_tabindex!(html_options)
    set_default_value!(method, options)    
    cms_options = options.extract!(:label, :instructions, :default_value)
    render_cms_form_partial :drop_down,
      :object_name => @object_name, :method => method,
      :choices => choices, :options => options, 
      :cms_options => cms_options, :html_options => html_options
  end  
    
  def cms_tag_list(options={})
    add_tabindex!(options)
    set_default_value!(:tag_list, options)    
    cms_options = options.extract!(:label, :instructions, :default_value)
    render_cms_form_partial :tag_list, 
      :options => options, :cms_options => cms_options
  end

  def cms_text_editor(method, options = {})
    add_tabindex!(options)
    set_default_value!(method, options)    
    cms_options = options.extract!(:label, :instructions, :default_value)
    render_cms_form_partial :text_editor, 
      :id => (options[:id] || "#{@object_name}_#{method}"), 
      :editor_enabled => (cookies["editorEnabled"].blank? ? true : (cookies["editorEnabled"] == 'true' || cookies["editorEnabled"] == ['true'])),
      :object_name => @object_name, :method => method, 
      :options => options, :cms_options => cms_options
  end

  private

    def set_default_value!(method, options={})
      if options.has_key?(:default_value) && @object.send(method).blank?
        @object.send("#{method}=", options[:default_value])
      end
    end
  
    def add_tabindex!(options)
      if options.has_key?(:tabindex)
        options.delete(:tabindex) if options[:tabindex].blank?
      else 
        options[:tabindex] = @template.next_tabindex
      end
      options
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

