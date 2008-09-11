#See /lib/initial_data.rb for info on how this works
create_user(:cmsadmin, :login => "cmsadmin", :email => "cmsadmin@example.com", :password => "cmsadmin", :password_confirmation => "cmsadmin")

create_section(:root, :name => "My Site")
create_section(:products, :name => "Products", :parent => sections(:root))
create_section(:browsercms, :name => "BrowserCMS", :parent => sections(:products))
create_section(:browserams, :name => "BrowserAMS", :parent => sections(:products))
create_section(:about, :name => "About", :parent => sections(:root))
create_section(:people, :name => "People", :parent => sections(:about))
create_section(:careers, :name => "Careers", :parent => sections(:about))

create_page_template(:main, :name => "Main", :file_name => "main", :language => "erb", :body => <<-TEMPLATE)
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><%= @page_title %></title>
    <%= stylesheet_link_tag 'cms' %>
    <%= yield :html_head %>
  </head>
  <body>
    <%= cms_toolbar %>
    <%= container :main %>
  </body>
</html>
TEMPLATE
create_page_template(:two_column, :name => "Two Column", :file_name => "two_column", :language => "erb", :body=> <<-TEMPLATE)
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><%= @page_title %></title>
    <%= stylesheet_link_tag 'cms' %>
    <%= yield :html_head %>
  </head>
  <body>
    <%= cms_toolbar %>
    <table width="960">
      <tr>
        <td width="720">
          <%= container :main %>
        </td>
        <td width="240">
          <%= container :sidebar %>
        </td>
      </tr>
    </table>
  </body>
</html>
TEMPLATE

create_page(:home, :name => "Home", :path => "/", :section => sections(:root), :template => page_templates(:two_column))
create_page(:about, :name => "About Us", :path => "/about", :section => sections(:about), :template => page_templates(:two_column))
create_page(:kerry, :name => "Kerry Gunther", :path => "/people/kerry", :section => sections(:people), :template => page_templates(:two_column))
create_page(:pat, :name => "Patrick Peak", :path => "/people/pat", :section => sections(:people), :template => page_templates(:two_column))
create_page(:paul, :name => "Paul Barry", :path => "/people/paul", :section => sections(:people), :template => page_templates(:two_column))

create_html_block(:hello_world, :name => "Hello World", :content => "<h1>Hello, World!</h1>")
create_html_block(:sidebar, :name => "Sidebar", :content => "<ul><li><a href=\"/\">Home</a></li><li><a href=\"/about\">About Us</a></li></ul>")
create_html_block(:about_us, :name => "About Us", :content => "We are super fantastic")

create_connector(:home_main, :page => pages(:home), :container => "main", :content_block => html_blocks(:hello_world))
create_connector(:home_sidebar, :page => pages(:home), :container => "sidebar", :content_block => html_blocks(:sidebar))
create_connector(:about_main, :page => pages(:about), :container => "main", :content_block => html_blocks(:hello_world))
create_connector(:about_sidebar, :page => pages(:about), :container => "sidebar", :content_block => html_blocks(:sidebar))

create_content_type(:html_block, :name => "HtmlBlock")
create_content_type(:portlet, :name => "Portlet")

create_portlet_type(:recently_updated_pages,
  :name => 'Recently Updated Pages',  
  :code => "@pages = Page.all(:order => 'updated_at desc', :limit => @portlet.number_of_pages)",
  :form => <<-FORM,
<div class="fields">
  <%= f.label :name %>
  <%= f.text_field :name %>
</div>
<div class="field">
  <%= f.label :number_of_pages %>
  <%= f.text_field :number_of_pages, :size => 2 %>
</div>
FORM
  :template => <<-TEMPLATE
<h2>Recent Updates</h2>
<ul>
  <% @pages.each do |page| %><li>
    <%= page.name %>
  </li><% end %>
</ul>
TEMPLATE
)
