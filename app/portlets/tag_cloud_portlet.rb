class TagCloudPortlet < Portlet
  
  def self.default_sizes
    (0..4).map{|n| "size-#{n}" }.join(" ")
  end
  
  def self.default_template
    template = <<-HTML
<div class="tag_cloud">
  <% for tag in @cloud %>
    <%= link_to h(tag.name), "/tags/\#{tag.name.to_slug}", :class => @sizes[tag.size] %>
  <% end %>
</div> 
    HTML
    template.chomp
  end
  
  def renderer(portlet)
    lambda do
      @portlet = portlet
      @sizes = @portlet.sizes.blank? ? @portlet.class.default_sizes : @portlet.sizes
      @limit = @portlet.limit.blank? ? 50 : @portlet.limit
      @cloud = Tag.cloud(:sizes => @sizes.size, :limit => @limit)
      render :inline => @portlet.template
    end
  end
    
end