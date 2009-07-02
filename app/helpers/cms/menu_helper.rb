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
    # You can change the behavior with the following options, all of these are optional:
    #
    # ==== Options
    # * <tt>:page</tt> - What page should be used as the current page.  If this value is omitted, the value in @page will be used.
    # * <tt>:path</tt> - This will be used to look up a section and that section will used to generate the menu.  The current page will
    #   still be the value of the page option or @page.  Note that this is the path to a section, not a path to a page.
    # * <tt>:from_top</tt> - How many below levels from the root the tree should start at.  
    #   All sections at this level will be shown.  The default is 0, which means show all
    #   section that are direct children of the root
    # * <tt>:depth</tt> - How many levels deep should the tree go, relative to from_top.  
    #   If no value is supplied, the tree will go all the way down to the current page.
    #   If a value is supplied, the tree will be that many levels underneath from_top deep.
    # * <tt>:limit</tt> - Limits the number of top-level elements that will be included in the list
    # * <tt>:class</tt> - The CSS Class that will be applied to the div.  The default value is "menu".
    # * <tt>:show_all_siblings</tt> - Passing true for this option will make all sibilings appear in the tree.
    #   the default is false, in which case only the siblings of nodes within the open path will appear.
    # 
    # ==== Examples
    #
    # Assume you have the structure the NFL, which is NFL > Conference > Division > Team,
    # with teams being a Page, everything else a Section.  Also, assume we are on the
    # Baltimore Ravens page. If you're not a footbal fan, see http://sports.yahoo.com/nfl/teams
    #
    #   render_menu
    #   # => <div class="menu">
    #     <ul>
    #       <li id="section_2" class="first open">
    #         <a href="/buf">AFC</a>
    #         <ul>
    #           <li id="section_3" class="first">
    #             <a href="/buf">East</a>
    #           </li>
    #           <li id="section_4" class="open">
    #             <a href="/bal">North</a>
    #             <ul>
    #               <li id="page_5" class="first on">
    #                 <a href="/bal">Baltimore Ravens</a>
    #               </li>
    #               <li id="page_6">
    #                 <a href="/cin">Cincinnati Bengals</a>
    #               </li>
    #               <li id="page_7">
    #                 <a href="/cle">Cleveland Browns</a>
    #               </li>
    #               <li id="page_8" class="last">
    #                 <a href="/pit">Pittsburgh Steelers</a>
    #               </li>
    #             </ul>
    #           </li>
    #           <li id="section_5">
    #             <a href="/hou">South</a>
    #           </li>
    #           <li id="section_6" class="last">
    #             <a href="/den">West</a>
    #           </li>
    #         </ul>
    #       </li>
    #       <li id="section_7" class="last">
    #         <a href="/dal">NFC</a>
    #       </li>
    #     </ul>
    #   </div>
    #
    #   render_menu(:depth => 2, :show_all_siblings => true)
    #   # => <div class="menu">
    #     <ul>
    #       <li id="section_2" class="first open">
    #         <a href="/buf">AFC</a>
    #         <ul>
    #           <li id="section_3" class="first">
    #             <a href="/buf">East</a>
    #           </li>
    #           <li id="section_4" class="open">
    #             <a href="/bal">North</a>
    #           </li>
    #           <li id="section_5">
    #             <a href="/hou">South</a>
    #           </li>
    #           <li id="section_6" class="last">
    #             <a href="/den">West</a>
    #           </li>
    #         </ul>
    #       </li>
    #       <li id="section_7" class="last">
    #         <a href="/dal">NFC</a>
    #         <ul>
    #           <li id="section_8" class="first">
    #             <a href="/dal">East</a>
    #           </li>
    #           <li id="section_9">
    #             <a href="/chi">North</a>
    #           </li>
    #           <li id="section_10">
    #             <a href="/atl">South</a>
    #           </li>
    #           <li id="section_11" class="last">
    #             <a href="/ari">West</a>
    #           </li>
    #         </ul>
    #       </li>
    #     </ul>
    #   </div>    
    def render_menu(options={})
      #Intialize parameters
      page = options[:page] || @page
      return nil unless page
      
      # Path to the section
      if options.has_key?(:path)
        section_for_path = Section.find_by_path(options[:path])
        raise "Could not find section for path '#{options[:path]}'" unless section_for_path
        ancestors = section_for_path.ancestors(:include_self => true)
      else
        ancestors = page.ancestors
      end
      
      from_top = options.has_key?(:from_top) ? options[:from_top].to_i : 0
      depth = options.has_key?(:depth) ? options[:depth].to_i : 1.0/0
      id = options[:id] || "menu"
      css_class = options[:class] || "menu"
      show_all_siblings = !!(options[:show_all_siblings])
      limit = options[:limit]

      html = "<div id=\"#{id}\" class=\"#{css_class}\">\n"
      
      if from_top > ancestors.size
        return html << "</div>\n"
      else
        ancestors = ancestors[from_top..-1]
      end
      
      #We are defining a recursive lambda that takes the top-level sections
      #d is the current depth
      fn = lambda do |nodes, d|
        indent = (d-1)*4
        html << "<ul>\n".indent(indent+2)
        nodes.each_with_index do |sn, i|

          #Construct the CSS classes that the LI should have
          classes = ["depth-#{d}"]
          if i == 0
            classes << "first"
          elsif i == nodes.size-1
            classes << "last"
          end
          classes << "open" if ancestors.include?(sn.node)
          classes << "on" if page == sn.node
          cls = classes.empty? ? nil : classes.join(" ")
          
          html << %Q{<li id="#{sn.node_type.underscore}_#{sn.node.id}"#{cls ? " class=\"#{cls}\"" : ''}>\n}.indent(indent+4)
          
          #Figure out what this link for this node should be
          #If it is a page, then the page will simply be used
          #But if is a page, we call the first_page_or_link method
          p = sn.node_type == "Section" ? sn.node.first_page_or_link : sn.node
          html << %Q{<a href="#{p ? p.path : '#'}"#{(p.respond_to?(:new_window) && p.new_window?) ? ' target="_blank"' : ''}>#{sn.node.name}</a>\n}.indent(indent+6)
          
          #Now if this is a section, we do the child nodes, 
          #but only if the show_all_siblings parameter is true, 
          #or if this section is one of the current page's ancestors
          #and also if the current depth is less than the target depth
          if sn.node_type == "Section" && (show_all_siblings || ancestors.include?(sn.node)) && d < depth
            fn.call(sn.node.visible_child_nodes, d+1)
          end
          
          html << %Q{</li>\n}.indent(indent+4)
          
        end
        html << "</ul>\n".indent(indent+2)
      end
      fn.call(ancestors.first.visible_child_nodes(:limit => limit), 1) unless ancestors.first.blank?
      html << "</div>\n"
    end
  end
end