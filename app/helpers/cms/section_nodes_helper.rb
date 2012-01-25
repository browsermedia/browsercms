module Cms
  module SectionNodesHelper

    def access_status(section_node, public_sections)
      access_icon = :unlocked
      unless public_sections.include?(section_node)
        access_icon = :locked
      end
      access_icon
    end

    def section_icons(section_node, children=[])
      folder_style = ""
      expander_image = "expand.png"
      if top_level_section?(section_node)
        folder_style = " large"
        expander_image = "gray_expand.png"
      end
      if children.empty?
        image_tag("cms/sitemap/no_contents.png", :class => "no_folder_toggle#{folder_style}")
      else
        image_tag("cms/sitemap/#{expander_image}", :class => "folder_toggle#{folder_style}")
      end
    end

    # Renders the ul for a given node (Page/Section/Link/etc)
    # Default look:
    #   - First level pages/sections use 'big' icons
    #   - All non-first level items should be hidden.
    def sitemap_ul_tag(node)
      opts = {
        :id => "section_node_#{node.section_node.id}",
        :class => "section_node"
      }
      opts[:class] += " rootlet" if in_first_level?(node)
      opts[:style] = "display: none" unless in_first_level?(node)
      tag("ul", opts, true)
    end

    def in_first_level?(node)
      node.section_node.depth == 1
    end

    private

    def top_level_section?(node)
      node.depth <= 2
    end

  end
end
