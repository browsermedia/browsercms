module Cms
  module SectionNodesHelper

    def draggable_class?(modifiable_sections, section_node, parent)
      if !section_node.root? && current_user_can_modify(modifiable_sections, section_node, parent)
        'draggable'
      else
        ''
      end
    end

    def add_page_path_data(section_node, parent_section_node)
      section = figure_out_target_section(parent_section_node, section_node)
      new_section_page_path(section)
    end

    def add_link_path_data(section_node, parent_section_node)
      section = figure_out_target_section(parent_section_node, section_node)
      new_section_link_path(section)
    end

    def add_section_path_data(section_node, parent_section_node)
      section = figure_out_target_section(parent_section_node, section_node)
      new_section_path(section_id: section)
    end

    # When sitemap initially renders, we only want to show first level.
    def initial_visibility_class(section_node)
      section_node.depth >= 1 ? 'hide' : ''
    end

    # Returns a css class for determine sitemap depth.
    def sitemap_depth_class(section_node)
      one_based_depth = section_node.depth + 1
      "level-#{one_based_depth}"
    end

    # Generate HTML for 'hidden' icon for hidden content.
    # @param [Object] content
    # @return [String] HTML (HTML safe)
    def hidden_icon_tag(content)
      if content.respond_to?(:hidden?) && content.hidden?
        '<span aria-hidden="true" class="permission-icon icon-eye-blocked"></span>'.html_safe
      else
        ''
      end
    end

    def guest_accessible_icon_tag(parent, content)
      unless content.accessible_to_guests?(@public_sections, parent)
        '<span aria-hidden="true" class="permission-icon icon-locked"></span>'.html_safe
      else
        ''
      end
    end

    # Generate the HTML for a given section node.
    def icon_tag(section_node, children)
      name = if section_node.ancestors.size == 0
               'earth'
             elsif section_node.home?
               'house'
             elsif section_node.link?
               'link'
             elsif section_node.page?
               'file'
             elsif section_node.section? && children.empty?
               'folder-open'
             elsif section_node.section?
               'folder'
             else
               'list' # All other content types.
             end
      content_tag("span", "", {'aria-hidden' => true, class: "type-icon icon-#{name}"})
    end

    # Marks a section to determine if it can be opened/closed in the sitemap.
    def closable_data(section_node, children)
      if (section_node.root?)
        false
      elsif !children.empty?
        true
      else
        false
      end
    end

    def current_user_can_modify(modifiable_sections, section_node, parent_section_node)
      if section_node.section?
        modifiable_sections.include?(section_node.node)
      else
        modifiable_sections.include?(parent_section_node.node)
      end
    end

    # Determines if a row is leaf or folder based on whether there are any subchildren.
    def row_type_tag(section_node)
      section_node.section? ? 'folder' : 'leaf'
    end

    private

    # Need to determine if we should be adding content to a node or its parent.
    def figure_out_target_section(parent_section_node, section_node)
      if section_node.section?
        section_node.node
      else
        parent_section_node.node
      end
    end
  end
end
