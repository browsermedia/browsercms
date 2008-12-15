class TagCloudPortlet < Portlet
  
  def self.default_sizes
    (0..4).map{|n| "size-#{n}" }.join(" ")
  end
  
  def self.default_template
    template = <<-HTML
<div class="tag-cloud">
  <% for tag in cloud %>
    <%= link_to h(tag.name), "/tags/\#{tag.name.to_slug}", :class => sizes[tag.size] %>
  <% end %>
</div> 
    HTML
    template.chomp
  end
  
  def renderer(portlet)
    lambda do
      locals = {:portlet => portlet}
      locals[:sizes] = portlet.sizes.blank? ? portlet.class.default_sizes : portlet.sizes
      locals[:limit] = portlet.limit.blank? ? 50 : portlet.limit
      locals[:cloud] = Tag.cloud(:sizes => locals[:sizes].size, :limit => locals[:limit])
      render :inline => portlet.template, :locals => locals
    end
  end
    
end