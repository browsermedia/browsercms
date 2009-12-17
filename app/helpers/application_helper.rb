# Any code for core CMS should go in /cms/application_helper.rb rather than here.
module ApplicationHelper

  def require_stylesheet_link(sources=(), content_area=:html_head)
    @required_stylesheet_links ||= []
    new_links = sources.to_a - @required_stylesheet_links
    if !new_links.empty?
      @required_stylesheet_links |= new_links
      content_for(content_area, stylesheet_link_tag(new_links))
    end
  end

  def require_javascript_include(sources=(), content_area=:html_head)
    @required_javascript_includes ||= []
    new_links = sources.to_a - @required_javascript_includes
    if !new_links.empty?
      @required_javascript_includes |= new_links
      content_for(content_area, javascript_include_tag(new_links))
    end
  end
end
