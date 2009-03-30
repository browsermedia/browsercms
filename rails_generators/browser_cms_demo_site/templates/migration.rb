class LoadDemoSiteData < ActiveRecord::Migration
  extend Cms::DataLoader
  
  def self.up
<%= data %>

    # Create templates
    <% page_templates.each do |pt| %>
<%= pt %>
    <% end %>

    # Create partials
    <% page_partials.each do |pp| %>
<%= pp %>
    <% end %>
  end
  
  def self.down
  end
  
end