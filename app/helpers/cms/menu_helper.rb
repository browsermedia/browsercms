module Cms
  module MenuHelper
    # This will render a menu based on the page
    # With no options passed, it will render a menu that shows all the child sections of the root
    # and then it will show the path of decendent sections all the way to the current page.
    # The resulting HTML is a DIV with a UL in it.  Each LI will have an A in it.  If the item is a Section,
    # the HREF of the A will be the URL of the first non-archived page that is a direct child of that Section.
    # Hidden pages will not show up, but if the first page in a Section is hidden, it will be used as the URL
    # for that Section.  This is commonly done to have a page for a Section and avoid having duplicates in the 
    # navigation.
    #
    # You can change the behavior with the following options:
    #
    # ==== Options
    # * <tt>:page</tt> - What page should be used.  If this value is omitted, the value in @page will be used.
    # * <tt>:from_top</tt> - How many below levels from the root the tree should start at.  
    #   All sections at this level will be shown.  The default is 0, which means show all
    #   section that are direct children of the root
    # * <tt>:depth</tt> - How many levels deep should the tree go.  If no value is supplied,
    #   the tree will go all the way down to the current page.  Must be greater than from_top.
    # * <tt>:class</tt> - The CSS Class that will be applied to the div.  The default value is "menu".
    # * <tt>:show_all_siblings</tt> - 
    # 
    # ==== Examples
    #
    # Assume you have the structure the NFL, which is NFL > Conference > Division > Team,
    # with teams being a Page, everything else a Section.  Also, assume we are on the
    # Baltimore Ravens page. If you're not a footbal fan, see http://sports.yahoo.com/nfl/teams
    #
    #   render_menu
    #   # => <div class="menu">
    #    <ul>
    #      <li class="first open">
    #        <a href="/buf">AFC</a>
    #        <ul>
    #          <li class="first"><a href="/buf">East</a></li>
    #          <li class="open">
    #            <a href="/bal">North</a>
    #            <ul>
    #              <li class="first on"><a href="/bal">Baltimore Ravens</a></li>
    #              <li><a href="/bal">Cincinnati Bengals</a></li>
    #              <li><a href="/bal">Cleveland Browns</a></li>
    #              <li class="last"><a href="/bal">Pittsburgh Steelers</a></li>
    #            </ul>
    #          </li>
    #          <li><a href="/hou">South</a></li>
    #          <li class="last"><a href="/den">East</a></li>
    #        </ul>
    #      </li>
    #      <li class="last">
    #        <a href="/dal">NFC</a>
    #      </li>
    #    </ul>
    #   </div>
    def render_menu(options={})
      page = options[:page] || @page
      from_top = options.has_key?(:from_top) ? options[:from_top].to_i : 0
      depth = options.has_key?(:depth) ? opts[:depth].to_i : 1.0/0
      css_class = options[:class] || "menu"
      
      ancestors = page.ancestors[from_top..-1]
      
      html = "<div class=\"#{css_class}\">\n"
      fn = lambda do |nodes, d|
        html << "<ul>\n".indent(d+2)
        nodes.each_with_index do |sn, i|

          classes = []          
          if i == 0
            classes << "first"
          elsif i == nodes.size-1
            classes << "last"
          end
          
          classes << "open" if ancestors.include?(sn.node)
          classes << "on" if page == sn.node
          cls = classes.empty? ? nil : classes.join(" ")
          html << %Q{<li id="#{sn.node_type.underscore}_#{sn.node.id}"#{cls ? " class=\"#{cls}\"" : ''}>\n}.indent(d+4)
          p = sn.node_type == "Section" ? sn.node.first_page : sn.node
          html << %Q{<a href="#{p ? p.path : '#'}">#{sn.node.name}</a>\n}.indent(d+6)
          if sn.node_type == "Section" && ancestors.include?(sn.node)
            fn.call(sn.node.child_nodes, d+4)
          end
          html << %Q{</li>\n}.indent(d+4)

        end
        html << "</ul>\n".indent(d+2)
      end
      fn.call(ancestors.first.child_nodes, 0)
      html << "</div>\n"
    end
  end
end