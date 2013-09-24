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

  end
end