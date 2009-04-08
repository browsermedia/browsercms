class TagCloudPortlet < Portlet
  
  def self.default_sizes
    (0..4).map{|n| "size-#{n}" }.join(" ")
  end
  
  def self.default_template
    template = <<-HTML
<% size_array = sizes.split(" ") %>
<div class="tag-cloud">
  <% for tag in cloud %>
    <%= link_to h(tag.name), "/tags/\#{tag.name.to_slug}", :class => size_array[tag.size] %>
  <% end %>
</div> 
    HTML
    template.chomp
  end
  
  def inline_options
    locals = {:portlet => portlet}
    locals[:sizes] = portlet.sizes.blank? ? portlet.class.default_sizes : portlet.sizes
    locals[:limit] = portlet.limit.blank? ? 50 : portlet.limit
    locals[:cloud] = Tag.cloud(:sizes => locals[:sizes].size, :limit => locals[:limit])
    { :inline => template, :locals => locals }
  end
    
end