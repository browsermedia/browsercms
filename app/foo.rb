class Foo
  def self.template
    template = <<-HTML
<div class="tag_cloud">
  <% for tag in @cloud %>
    <%= link_to h(tag.name), "/tags/\#{tag.name.to_slug}", :class => @portlet.tag_sizes[tag.size] %>
  <% end %>
</div> 
    HTML
    template.chomp
  end
end

puts "'#{Foo.template}'"