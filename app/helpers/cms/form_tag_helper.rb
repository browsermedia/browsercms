module Cms
  module FormTagHelper

    # Generates a form (i.e. Rails form_for) for creating/updating content blocks. Exposes additional methods to
    # to create inputs. Implements a superset of SimpleForm behavior (i.e. simple_form_for).
    #
    # This also includes deprecated methods from pre-4.0 form building (like f.cms_text_field) for backwards compatiable
    # support.
    def content_block_form_for(object, *args, &block)
      options = args.extract_options!
      simple_form_for(object, *(args << options.merge(builder: Cms::FormBuilder::ContentBlockFormBuilder)), &block)
    end


    def forecasting_a_new_section?(form_object)
      Cms::Section.with_path(form_object.object.class.path).first.nil?
    end

    def slug_source_if(boolean)
      if boolean
        {input_html: {class: 'slug-source'}}
      else
        {}
      end
    end

    def content_requires_slug_field?(method, form_object)
      method == :name && form_object.object.class.requires_slug?
    end

    def should_autogenerate_slug?(method, form_object)
      content_requires_slug_field?(method, form_object) && form_object.object.new_record?
    end

    # A drop-down is just a specialized HTML select
    
    def drop_down_tag(name, option_tags = nil, options = {}) 
      select_tag(name, option_tags, options)
    end
    
    def drop_down(object, method, choices, options = {}, html_options = {})
      select(object, method, choices, options, html_options)
    end
    
    # A text editor is an HTML WYSIWYG editor.  The result of this
    # will be a div with a select and a textarea in it.
    
    def text_editor_options(options={})
      opts = options.dup
      (opts[:class] ||= "") << " editor"
      opts
    end
    
    def text_editor_tag(name, content = nil, options = {})
      text_area_tag(name, content, text_editor_options(options))
    end
    
    def text_editor(object_name, method, options = {})
      text_area(object_name, method, text_editor_options(options))
    end
        
  end
end