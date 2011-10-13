module Cms
  module MenuHelper
    # Renders a menu. There are two options, neither are required:
    # 
    # ==== Options
    # * <tt>:items</tt> - The items which should appear in the menu. This defaults to calling 
    #   menu_items which generates items automatically based on the current page. But you can use 
    #   this option to pass in a custom menu structure.
    # * <tt>:partial</tt> - The partial used to render the menu. By default this is "partials/menu",
    #   which can be customised through the CMS. The partial gets a local variable <tt>items</tt>.
    #
    # ==== Structure of items
    #
    # The items should be an array of hashes, in a tree. Each hash can have the following keys (name
    # and url are required, others are optional):
    # 
    # * <tt>:name</tt> - The name which appears in the menu
    # * <tt>:url</tt> - The URL to link to
    # * <tt>:id</tt> - The id for the menu item
    # * <tt>:selected</tt> - Boolean value to indicate whether the menu item is the current page
    # * <tt>:target</tt> - The target attribute for the link
    # * <tt>:children</tt> - An array of hashes containing the child menu items. This is where the
    #   tree structure comes in.
    #
    # Edge Cases:
    #   If both @page and :items are nil/empty, this will return an empty string. This might happen if used on an CMS
    #   rendered page, where @page isn't set.
    #
    def render_menu(options = {})
      options[:items] ||= menu_items(options)
      return "" unless options[:items]

      options[:partial] ||= "cms/menus/menu"
      options[:id] ||= "menu"
      options[:class] ||= "menu"
      render :partial => options[:partial], :locals => { :items => options[:items], :css_id => options[:id], :css_class => options[:class] }
    end
    
    # This will render generate an array-of-hashes tree structure based on the page, which can be
    # passed to render_menu in order to generate a menu.
    # 
    # With no options passed, it will generate a structure that includes all the child sections of 
    # the root and then it will include the path of decendent sections all the way to the current
    # page.
    # 
    # Hidden pages will not be included, but if the first page in a Section is hidden, it will be
    # used as the URL for that Section. This is commonly done to have a page for a Section and avoid
    # having duplicates in the navigation.
    # 
    # You can change the behavior with the following options, all of these are optional:
    #
    # ==== Options
    # * <tt>:page</tt> - What page should be used as the current page.  If this value is omitted, 
    #   the value in @page will be used.
    # * <tt>:path</tt> - This will be used to look up a section and that section will used to 
    #   generate the menu structure. The current page will still be the value of the page option or
    #   @page. Note that this is the path to a section, not a path to a page.
    # * <tt>:from_top</tt> - How many below levels from the root the tree should start at.  
    #   All sections at this level will be shown.  The default is 0, which means show all
    #   nodes that are direct children of the root
    # * <tt>:depth</tt> - How many levels deep should the tree go, relative to from_top.  
    #   If no value is supplied, the tree will go all the way down to the current page.
    #   If a value is supplied, the tree will be that many levels underneath from_top deep.
    # * <tt>:limit</tt> - Limits the number of top-level elements that will be included in the list
    # * <tt>:show_all_siblings</tt> - Passing true for this option will make all sibilings appear in
    #   the tree. The default is false, in which case only the siblings of nodes within the open
    #   path will appear.
    # 
    # ==== Examples
    #
    # Assume you have the structure the NFL, which is NFL > Conference > Division > Team,
    # with teams being a Page, everything else a Section.  Also, assume we are on the
    # Baltimore Ravens page. If you're not a footbal fan, see http://sports.yahoo.com/nfl/teams
    #
    #   menu_items
    #   # => [
    #     { :id => "section_2", :url => "/buf", :name => "AFC", :children => [
    #       { :id => "section_3", :url => "/buf", :name => "East" },
    #       { :id => "section_4", :url => "/bal", :name => "North", :children => [
    #         { :id => "page_5", :selected => true, :url => "/bal", :name => "Baltimore Ravens" },
    #         { :id => "page_6", :url => "/cin", :name => "Cincinnati Bengals" },
    #         { :id => "page_7", :url => "/cle", :name => "Cleveland Browns" },
    #         { :id => "page_8", :url => "/pit", :name => "Pittsburgh Steelers" }
    #       ] },
    #       { :id => "section_9", :url => "/hou", :name => "South" },
    #       { :id => "section_10}", :url => "/den", :name => "West" }
    #       ] },
    #     { :id => "section_11", :url => "/dal", :name => "NFC" }
    #   ]
    #
    #   menu_items(:depth => 2, :show_all_siblings => true)
    #   # => [
    #     { :id => "section_2", :url => "/buf", :name => "AFC", :children => [
    #         { :id => "section_3", :url => "/buf", :name => "East" },
    #         { :id => "section_4", :url => "/bal", :name => "North" },
    #         { :id => "section_5", :url => "/hou", :name => "South" },
    #         { :id => "section_6", :url => "/den", :name => "West" }
    #       ] },
    #     { :id => "section_7", :url => "/dal", :name => "NFC", :children => [
    #         { :id => "section_8", :url => "/dal", :name => "East" },
    #         { :id => "section_9", :url => "/chi", :name => "North" },
    #         { :id => "section_10", :url => "/atl", :name => "South" },
    #         { :id => "section_11", :url => "/ari", :name => "West" }
    #       ] }
    #   ]
    def menu_items(options = {})
      # Intialize parameters
      selected_page = options[:page] || @page
      return nil unless selected_page
      
      # Path to the section
      if options.has_key?(:path)
        section_for_path = Section.find_by_path(options[:path])
        raise "Could not find section for path '#{options[:path]}'" unless section_for_path
        ancestors = section_for_path.ancestors(:include_self => true)
      else
        ancestors = selected_page.ancestors
      end
      
      if options.has_key?(:from_top)
        ancestors = ancestors[options[:from_top].to_i..-1] || []
      end
      
      depth = options.has_key?(:depth) ? options[:depth].to_i : 1.0/0
      show_all_siblings = options[:show_all_siblings] || false
      
      # We are defining a recursive lambda that takes the top-level sections
      fn = lambda do |section_nodes, current_depth|
        section_nodes.map do |section_node|
          node = section_node.node
          
          item = {}
          item[:id] = "#{section_node.node_type.gsub("::","_").underscore}_#{section_node.node_id}"
          
          # If we are showing a section item, we want to use the path for the first page
          page_or_link = section_node.section? ? node.first_page_or_link : node
          if section_node.section? && page_or_link
            item[:selected] = true if page_or_link.respond_to?(:hidden?) && page_or_link.hidden? && selected_page == page_or_link
          else
            item[:selected] = true if selected_page == page_or_link
          end
         
          item[:url] = page_or_link.try(:path) || '#'
          item[:name] = node.name
          item[:target] = "_blank" if page_or_link.respond_to?(:new_window?) && page_or_link.new_window?
          
          # Now if this is a section, we do the child nodes, 
          # but only if the show_all_siblings parameter is true, 
          # or if this section is one of the current page's ancestors
          # and also if the current depth is less than the target depth
          if section_node.section? &&
             current_depth < depth &&
             (show_all_siblings || ancestors.include?(node)) &&
             !node.visible_child_nodes.empty?
            item[:children] = fn.call(node.visible_child_nodes, current_depth + 1)
          end
          
          item
        end
      end
      
      if ancestors.empty?
        []
      else
        fn.call(ancestors.first.visible_child_nodes(:limit => options[:limit]), 1)
      end
    end
  end
end
