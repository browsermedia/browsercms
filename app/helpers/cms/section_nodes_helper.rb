module Cms
  module SectionNodesHelper
    def section_icons(node)
      
      if (node.root? || node.parent.root? || node.parent.parent.root?)
        node.child_nodes.empty? ? image_tag("cms/sitemap/no_contents.png", :class => "no_folder_toggle large") : image_tag("cms/sitemap/gray_expand.png", :class => "folder_toggle large")
      else
        node.child_nodes.empty? ? image_tag("cms/sitemap/no_contents.png", :class => "no_folder_toggle") : image_tag("cms/sitemap/expand.png", :class => "folder_toggle")
      end
    end

  end
end
