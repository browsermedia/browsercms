module Cms
  module MenuHelper
    def render_menu(options={})
      opts = {:from_top => 1, :depth => 2, :class => "leftnav"}.merge(options)
      render_section_in_menu(Section.root.first, 0, opts[:from_top], opts[:depth], opts[:class])
    end
	  
	  def render_section_in_menu(section, depth, min_depth, max_depth, css_class)
	    html = "<ul>"
	    html << @page.name
	    html << "</ul>"
	    html
	  end    
  end
end