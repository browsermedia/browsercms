module Cms
  module SectionNodesHelper

    def section_icons(node)
      folder_style = ""
      expander_image = "expand.png"
      if top_level_section?(node)
        folder_style = " large"
        expander_image = "gray_expand.png"
      end
      if  node.child_nodes.empty?
        image_tag("cms/sitemap/no_contents.png", :class => "no_folder_toggle#{folder_style}")
      else
        image_tag("cms/sitemap/#{expander_image}", :class => "folder_toggle#{folder_style}")
      end
    end

    private
    def top_level_section?(node)
      node.node.depth <= 2
    end

  end
end
