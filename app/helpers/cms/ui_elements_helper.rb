module Cms
  module UiElementsHelper

    # Renders a Save And Publish button if:
    # 1. Current User has publish rights
    # 2. Block is publishable
    def save_and_publish_button(block, content_type)
      if current_user.able_to?(:publish_content) && block.publishable?
        html = %Q{<button type="submit" name="#{content_type.content_block_type.singularize}[publish_on_save]" value="true" class="submit" tabindex="#{next_tabindex}"><span>Save And Publish</span></button>}
        lt_button_wrapper html.html_safe
      end
    end

    # For simple publish buttons
    def publish_button(type)
      html = %Q{<button type="submit" name="#{type}[publish_on_save]" value="true" class="submit"><span>Save And Publish</span></button>'}
      lt_button_wrapper html.html_safe
    end


    def select_content_type_tag(type, &block)
      options = {:rel => "select-#{type.key}"}
      options[:class] = "on" if content_type == type
      content_tag_for(:li, type, nil, options, &block)
    end
  end
end