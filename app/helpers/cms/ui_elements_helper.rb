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

    # Renders a Publish button for the menu based on whether:
    #   1. The current user can publish
    #   2. The content item can or needs to be published.
    def publish_menu_button(content_item)
      options = {class: ["btn", "http_put"], id: "publish_button"}
      path = "#"
      if current_user.able_to?(:publish_content) && !content_item.new_record? && content_item.respond_to?(:live?) && !content_item.live?
        options[:class] << "btn-primary"
        path = block_path(@block, :publish)
      else
        options[:class] << "disabled"
      end
      link_to "Publish", path, options
    end

    def edit_content_menu_button(content_item)
      path = "#"
      unless content_item.new_record?
        path = block_path(content_item, :edit)
      end
      link_to "Edit Content", path, class: "btn btn-primary", id: "edit_button"
    end

    def view_content_menu_button(content_item)
      path = "#"
      unless content_item.new_record?
        path = block_path(content_item)
      end
      link_to "View Content", path, class: "btn btn-primary", id: "view_button"
    end

    def versions_menu_button(content_item)
      options = {class: ["btn"], id: "revisions_button"}
      path = content_item.new_record? ? "#" : block_path(content_item, :versions)

      if content_item.class.versioned?
        options[:class] << "btn-primary"
      else
        options[:class] << "disabled"
      end
      link_to "List Versions", path, options
    end

    # Render a CMS styled 'X Delete' button. This button will appear on tool bars, typically set apart visually from other buttons.
    # Has a 'confirm?' popup attached to it as well.
    # Assumes that javascript code to handle the 'confirm' has already been included in the page.
    #
    # @param [Hash] options The options for this tag
    # @option options [String or Boolean] :title Title for 'confirm' popup. If specified as 'true' or with a string value a standard 'confirm yes/no' window should be used. If true is specified, its assume that the javascript popup handles the title.
    # @option options [Path] :path The path or URL to link_to. Takes same types at url_for or link_to. Defaults to '#' if not specified.
    # @option options [Boolean] :enabled If false, the button will be marked disabled. Default to false.
    def delete_button(options={})
      classes = "button"
      classes << " disabled" if !options[:enabled]
      classes << " delete_button"
      classes << " http_delete confirm_with_title" if options[:title]

      link_to_path = options[:path] ? options[:path] : "#"

      span_options = {:id => 'delete_button', :class => classes}
      span_options[:title] = options[:title] if (!options[:title].blank? && options[:title].class == String)
      link_to span_tag("<span class=\"delete_img\">&nbsp;</span>Delete".html_safe), link_to_path, span_options
    end

    # Render a CMS styled 'Delete' button. This button will appear on tool bars, typically set apart visually from other buttons.
    # Has a 'confirm?' popup attached to it as well.
    # Assumes that javascript code to handle the 'confirm' has already been included in the page.
    #

    def delete_menu_button(content_item)
      classes = ["btn", "http_delete", "confirm_with_title"]
      if current_user.able_to_publish?(content_item)
        classes << 'btn-primary'
      else
        classes << 'disabled'
      end

      link_to_path = block_path(content_item)
      options = {:id => 'delete_button', :class => classes}
      options[:title] = "Are you sure you want to delete '#{content_item.name}'?"

      if content_item.new_record?
        link_to_path = "#"
        classes.delete("confirm_with_title")
        classes.delete("http_delete")
      end
      link_to "Delete", link_to_path, options
    end

    def select_content_type_tag(type, &block)
      options = {:rel => "select-#{type.key}"}
      if (defined?(content_type) && content_type == type)
        options[:class] = "on"
      end
      content_tag_for(:li, type, nil, options, &block)
    end

    # Used by Twitter Bootstrap dropdown menus used to divide groups of menu items.
    # @param [Integer] index
    def divider_tag(index = 1)
      tag(:li, class: "divider") if index != 0
    end

    def nav_link_to(name, link, options={})
      content_tag(:li, link_to(name, link, options.merge({:target => "_top"})))
    end
  end
end