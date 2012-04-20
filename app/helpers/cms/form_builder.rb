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
    cms_options = options.extract_only!(:default_value, :width)
    render_cms_form_partial :fancy_drop_down,
                            :object_name => @object_name, :method => method,
                            :choices => choices, :options => opts,
                            :cms_options => cms_options, :html_options => h_opts
  end

  def date_picker(method, options={})
    text_field(method, {:size => 10, :class => "date_picker", :value => Cms::DatePicker.format_for_ui(@object.send(method))}.merge(options))
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

  # Returns a label for a given field
  # @param [Symbol] field Name of the field
  # @param [String] label_value If nil, will use default logic for Rails::FormBuilder#label
  def cms_label(field, label_value)
    if label_value
      label field, label_value
    else
      label field
    end
  end

  # Returns a file upload input tag for a given block, along with label and instructions.
  #
  # @param [Symbol] method The name of the model this form upload is associated with
  # @param [Hash] options
  # @option options [String] :label (Data)
  # @option options [String] :instructions (blank) Helpful tips for the person entering the field, appears blank if nothing is specified.
  # @option options [Boolean] :edit_path (false) If true, render a text field to allow users to edit path for this file.
  # @option options [Boolean] :edit_section (false) If true, render a select box which allows users to choose which section this attachment should be placed in.
  def cms_file_field(method, options={})
    @object.ensure_attachment_exists if @object.respond_to?(:ensure_attachment_exists)
    render_form_field("file_field", method, options)
  end

  # Renders a multiple file uploader for attachments. Allows users to add as many attachments to this model as needed.
  def cms_attachment_manager
    defs = Cms::Attachment.definitions_for(object.class.name, :multiple)
    names = defs.keys.sort
    return if names.empty?

    names.unshift "Select a type to upload a file" if names.size > 1
    render_cms_form_partial :attachment_manager, :asset_definitions => defs, :asset_types => names
  end

  # @params html_options
  # @options html_option [:class] - This will be overridden, so don't bother to set it
  def cms_drop_down(method, choices, options={}, html_options={})
    add_tabindex!(html_options)
    set_default_value!(method, options)
    cms_options = options.extract_only!(:label, :instructions, :default_value)
    render_cms_form_partial :drop_down,
                            :object_name => @object_name, :method => method,
                            :choices => choices, :options => options,
                            :cms_options => cms_options, :html_options => html_options
  end

  def cms_tag_list(options={})
    add_tabindex!(options)
    set_default_value!(:tag_list, options)
    cms_options = options.extract_only!(:label, :instructions, :default_value)
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
    cms_options = options.extract_only!(:label, :instructions, :default_value)
    render_cms_form_partial :text_editor,
                            :id => (options[:id] || "#{@object_name}_#{method}"),
                            :editor_enabled => (cookies["editorEnabled"].blank? ? true : (cookies["editorEnabled"] == 'true' || cookies["editorEnabled"] == ['true'])),
                            :object_name => @object_name, :method => method,
                            :options => options, :cms_options => cms_options
  end

  # Renders instructions for a given field below the field itself. Instructions can be used to provide helpful
  # guidance to content editors including formatting help or just explaining what a field is for.
  #
  # If instructions are blank/nil, then nothing will be shown.
  #
  # @param [String] instructions (blank) The help text to show
  def cms_instructions(instructions)
    render_cms_form_partial :instructions, :instructions => instructions
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
    cms_options = options.extract_only!(:label, :instructions, :default_value)
    render_cms_form_partial "check_box", :method => method, :options => options, :cms_options => cms_options
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

      cms_options = options.extract_only!(:label, :instructions)
      dropdown_options = options.extract_only!(:default_handler)
      add_tabindex!(options)
      render_cms_form_partial :template_editor, :method => method, :dropdown_options => dropdown_options, :options => options, :cms_options => cms_options
    end
  end


  # Basic replacement for the error_messages provided by Rails 2, which were deprecated/removed in Rails 3.
  def cms_error_messages
    return unless object.respond_to?(:errors) && object.errors.any?

    errors_list = ""
    errors_list << @template.content_tag(:h2, "#{object.errors.size} error prohibited this #{object_name.humanize} from being saved.".html_safe)
    errors_list << @template.content_tag(:p, "There were problems with the following fields:")
    errors_list << @template.content_tag(:ul, object.errors.full_messages.map { |message| @template.content_tag(:li, message).html_safe }.join("\n").html_safe).html_safe

    @template.content_tag(:div, errors_list.html_safe, :class => "errorExplanation", :id => "errorExplanation")
  end

  private

  def render_form_field(form_control_name, method, options)
    add_tabindex!(options)
    set_default_value!(method, options)
    cms_options = options.extract!(:label, :instructions, :default_value)
    render_cms_form_partial form_control_name.to_sym,
                            :model_object => @object,
                            :object_name => @object_name,
                            :method => method,
                            :options => options,
                            :cms_options => cms_options
  end

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
    @template.render :partial => "cms/form_builder/cms_#{field_type_name}", :locals => {:f => self}.merge(locals)
  end

end

