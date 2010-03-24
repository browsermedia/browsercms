#
# Adds additional form fields to the Rails FormBuilder which can be used to create CMS forms.
#
class Cms::FormBuilder < ActionView::Helpers::FormBuilder


  # Renders a CMS styled JavaScript/CSS styled select box, by itself with no label or other markup besides the js.
  #
  # Options:
  #   * All standard select tag options plus:
  #   * :default_value - The default item to have selected (defaults to the value of the underlying model)
  #   * :width - The width for the select (defaults to 455px).
  #
  def drop_down(method, choices, options = {}, html_options = {})
    select_class = "#{@object_name}_#{method}"
    h_opts = add_tabindex!(@default_options.merge(html_options))
    h_opts[:class] = select_class

    opts = objectify_options(options)
    set_default_value!(method, options)
    cms_options = options.extract!(:default_value, :width)
    render_cms_form_partial :fancy_drop_down,
                            :object_name => @object_name, :method => method,
                            :choices => choices, :options => opts,
                            :cms_options => cms_options, :html_options => h_opts
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
        cms_options = options.extract!(:label, :instructions, :default_value, :fancy)
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

  #
  # Renders a WYWIWYG editor without the 'type' selector.
  #
  def text_editor(method, options = {})
    @template.send(
            "text_editor",
            @object_name,
            method,
            objectify_options(options))
  end

  # Renders a WYWIWYG editor with the 'type' selector. 
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

  # Renders instructions for a given field below the field itself. Instructions can be used to provide helpful
  # guidance to content editors including formatting help or just explaining what a field is for.
  #
  # Will not render if instructions are blank/nil.
  #
  # * instructions - The text of the instructions to show (Defaults to blank)
  def cms_instructions(instructions)
    render_cms_form_partial :instructions, :instructions=>instructions
  end

  # Renders a label and checkbox suitable for allow editors to update a boolean field.
  #
  # Params:
  #   * method - The name of the field this check_box will update.
  #   * options - Hash of values including:
  #       - :label
  #       - :instructions
  #       - :default_value
  #       - Any other standard FormBuilder.check_box options that will be passed directly to the check_box method.
  def cms_check_box(method, options={})
    add_tabindex!(options)
    set_default_value!(method, options)
    cms_options = options.extract!(:label, :instructions, :default_value)
    render_cms_form_partial "check_box", :method=>method, :options => options, :cms_options => cms_options
  end

  #
  # Renders a template editor that allows developers to edit the view used to render a specific block. Render both
  # a 'Handler' select box (erb, builder, etc) and a text_area for editing. Will not display the editor if the underlying
  # object is marked as 'render_inline(false)'. This allows developers to edit the render.html.erb directly to update
  # how the model displays.
  #
  # For example, Portlets will often specify a :template to allow runtime update of their view.
  #
  # Options:
  #   :default_handler - Which handler will be the default when creating new instances. (Defaults to erb)
  #   :instructions - Instructions that will be displayed below the text area. (Blank by default)
  #   :label - The name for the label (Defaults to humanized version of field name)
  #                                                                               
  def cms_template_editor(method, options={})
    if object.class.render_inline

      # Set some defaults
      options[:default_value] = @object.class.default_template
      set_default_value!(method, options)
      options[:default_handler] = "erb" unless options[:default_handler]

      cms_options = options.extract!(:label, :instructions)
      dropdown_options = options.extract!(:default_handler)
      add_tabindex!(options)
      render_cms_form_partial :template_editor, :method=>method, :dropdown_options=>dropdown_options, :options => options, :cms_options=>cms_options
    end
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

