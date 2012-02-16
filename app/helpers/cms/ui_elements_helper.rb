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

  end
end