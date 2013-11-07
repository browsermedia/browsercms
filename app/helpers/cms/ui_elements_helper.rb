module Cms

  # Defines functions for creating buttons and links using the CMS styling.
  # I.e. Menus, Save, Publish buttons and links.
  module UiElementsHelper

    # Renders a Save And Publish button if:
    # 1. Current User has publish rights
    # 2. Block is publishable
    def save_and_publish_button(block, content_type)
      if current_user.able_to?(:publish_content) && block.publishable?
        html = %Q{<button type="submit" name="#{content_type.content_block_type.singularize}[publish_on_save]" value="true" class="submit btn btn-primary" tabindex="#{next_tabindex}"><span>Save And Publish</span></button>}
        html.html_safe
      end
    end

    # For simple publish buttons
    def publish_button(type)
      html = %Q{<button type="submit" name="#{type}[publish_on_save]" value="true" class="submit btn btn-primary"><span>Save And Publish</span></button>'}
      html.html_safe
    end

    # Renders a Publish button for the menu based on whether:
    #   1. The current user can publish
    #   2. The content item can or needs to be published.
    def publish_menu_button(content_item)
      options = {class: ["btn", "btn-primary", "http_put"], id: "publish_button"}
      path = "#"
      if current_user.able_to?(:publish_content) && !content_item.new_record? && content_item.respond_to?(:live?) && !content_item.live?
        path = engine(@block).polymorphic_path([:publish, @block])
      else
        options[:class] << "disabled"
      end
      link_to "Publish", path, options
    end

    def edit_content_menu_button(content_item)
      path = "#"
      unless content_item.new_record?
        path = edit_engine_aware_path(content_item)
      end
      link_to "Edit Content", path, class: "btn btn-primary", id: "edit_button"
    end

    def view_content_menu_button(content_item)
      path = "#"
      unless content_item.new_record?
        path = engine_aware_path(content_item, nil)
      end
      link_to "View Content", path, class: "btn btn-primary", id: "view_button"
    end


    # Generic bootstrap based menu button
    # @param [Hash] options
    # @option options [Boolean] :enabled
    # @option options [Array<String>] :class An array of additional classes to apply
    def menu_button(label, path, options={})
      defaults = {
          enabled: true,
          pull: 'left'
      }
      options = defaults.merge!(options)
      options[:class] = %w{btn btn-primary}
      if (options[:pull] == 'left' || options[:pull]== 'right')
        options[:class] << "pull-#{options.delete(:pull)}"
      end

      options[:class] << 'disabled' unless options[:enabled]
      options.delete(:enabled)
      options[:class] << 'http_put' if options[:method] == :put
      options[:class] << 'http_delete' if options[:method] == :delete
      options[:class] << 'confirm_with_title' if options[:method] == :delete

      options.delete(:method)
      copy_title(options, options)
      link_to(label, path, options)
    end

    def versions_menu_button(content_item)
      options = {class: ["btn", "btn-primary"], id: "revisions_button"}
      path = "#"
      if !content_item.new_record? && content_item.class.versioned?
        path = engine(content_item).polymorphic_path([:versions, content_item])
      else
        options[:class] << "disabled"
      end
      link_to "List Versions", path, options
    end

    # Render a CMS styled 'Delete' button. This button will appear on tool bars, typically set apart visually from other buttons.
    # Has a 'confirm?' popup attached to it as well.
    # Assumes that javascript code to handle the 'confirm' has already been included in the page.
    #
    def delete_menu_button(content_item=nil, opts={class: []})
      classes = ["btn", "http_delete", "confirm_with_title"]
      if current_user.able_to_publish?(content_item)
        classes << 'btn-primary'
      else
        classes << 'disabled'
      end

      link_to_path = "#"
      options = {:id => 'delete_button', :class => classes}
      options[:class].concat(opts[:class]) if opts[:class]

      if content_item == nil || content_item.new_record?
        classes << 'disabled'
      else
        options[:title] = "Are you sure you want to delete '#{content_item.name}'?"
        link_to_path = engine_aware_path(content_item, nil)
      end
      if opts[:title]
        options[:title] = opts[:title]
      end
      link_to "Delete", link_to_path, options
    end

    def select_content_type_tag(type, &block)
      options = {:rel => "select-#{type.param_key}"}
      if (defined?(content_type) && content_type == type)
        options[:class] = "on"
      end
      content_tag_for(:li, type, nil, options, &block)
    end

    # Used by Twitter Bootstrap dropdown menus used to divide groups of menu items.
    # @param [Integer] index
    def divider_tag(index = 1)
      content_tag(:li, "&nbsp;", {class: "divider"}) if index != 0
    end

    def nav_link_to(name, link, options={})
      content_tag(:li, link_to(name, link, options))
    end

    private

    def copy_title(from, to)
      to[:title] = from[:title] if (!from[:title].blank? && from[:title].class == String)
    end

  end
end