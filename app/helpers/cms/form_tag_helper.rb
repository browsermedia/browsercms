module Cms
  module FormTagHelper
    
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