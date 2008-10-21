#See /lib/initial_data.rb for info on how this works
create_user(:cmsadmin, :login => "cmsadmin", :email => "cmsadmin@example.com", :password => "cmsadmin", :password_confirmation => "cmsadmin")
create_group(:guest, :name => 'Guest', :code => 'guest', :group_type => 'Guest')
create_group(:search_bot, :name => 'Search Bot', :code => 'search_bot', :group_type => 'Search Bot')
create_group(:content_admin, :name => 'Cms Administrators', :code => 'cms-admin', :group_type => 'CMS User')
create_group(:content_editor, :name => 'Content Editors', :code => 'content-editor', :group_type => 'CMS User')
users(:cmsadmin).groups << groups(:content_admin)
users(:cmsadmin).groups << groups(:content_editor)

create_permission(:admin, :name => "cms-administrator", :full_name => "Administer CMS" , :description => "Allows users to administer the CMS, including adding users and groups.")
create_permission(:author, :name => "editor", :full_name => "Author Content" , :description => "Allows users to Add, Edit and Delete both Pages and Blocks. Can Save (but not Publish) and Assign them as well.")
create_permission(:publish, :name => "publish-page", :full_name => "Publish Content" , :description => "Allows users to Save and Publish, Hide and Archive both Pages and Blocks.")
groups(:content_admin).permissions<<permissions(:admin)
groups(:content_editor).permissions<<permissions(:author)
groups(:content_editor).permissions<<permissions(:publish)

create_site(:default, :name => "Default", :domain => "example.com")
create_section(:root, :name => "My Site", :path => "/", :root => true)
create_section(:products, :name => "Products", :parent => sections(:root), :path => "/products")
create_section(:browsercms, :name => "BrowserCMS", :parent => sections(:products), :path => "/browsercms")
create_section(:browserams, :name => "BrowserAMS", :parent => sections(:products), :path => "/browserams")
create_section(:about, :name => "About", :parent => sections(:root), :path => "/about")
create_section(:people, :name => "People", :parent => sections(:about), :path => "/people")
create_section(:careers, :name => "Careers", :parent => sections(:about), :path => "/careers")

groups(:guest).sections << sections(:root)
groups(:search_bot).sections << sections(:root)

create_page_template(:main, :name => "Main", :file_name => "main", :language => "erb", :body => <<-TEMPLATE)
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><%= @page_title %></title>
    <%= stylesheet_link_tag 'cms/application' %>
    <%= javascript_include_tag :defaults %>    
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
    <%= stylesheet_link_tag 'cms/application' %>
    <%= javascript_include_tag :defaults %>    
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

create_page(:home, :name => "Home", :path => "/", :section => sections(:root), :template => page_templates(:two_column), :updated_by_user => users(:cmsadmin))
create_page(:about, :name => "About Us", :path => "/about", :section => sections(:about), :template => page_templates(:two_column), :updated_by_user => users(:cmsadmin))
create_page(:kerry, :name => "Kerry Gunther", :path => "/people/kerry", :section => sections(:people), :template => page_templates(:two_column), :updated_by_user => users(:cmsadmin))
create_page(:pat, :name => "Patrick Peak", :path => "/people/pat", :section => sections(:people), :template => page_templates(:two_column), :updated_by_user => users(:cmsadmin))
create_page(:paul, :name => "Paul Barry", :path => "/people/paul", :section => sections(:people), :template => page_templates(:two_column), :updated_by_user => users(:cmsadmin))

create_page(:test, :name => "Test", :path => "/test", :section => sections(:root), :template => page_templates(:main), :updated_by_user => users(:cmsadmin))
create_html_block(:test, :name => "Test", :connect_to_page_id => pages(:test).id, :connect_to_container => "main", :updated_by_user => users(:cmsadmin))
pages(:test).publish!(users(:cmsadmin))

create_html_block(:hello_world, :name => "Hello World", :content => "<h1>Hello, World!</h1>", :new_status => "PUBLISHED", :updated_by_user => users(:cmsadmin))
create_html_block(:sidebar, :name => "Sidebar", :content => "<ul><li><a href=\"/\">Home</a></li><li><a href=\"/about\">About Us</a></li></ul>", :new_status => "PUBLISHED", :updated_by_user => users(:cmsadmin))
create_html_block(:about_us, :name => "About Us", :content => "We are super fantastic", :new_status => "PUBLISHED", :updated_by_user => users(:cmsadmin))

pages(:home).add_content_block!(html_blocks(:hello_world), "main")
pages(:home).add_content_block!(html_blocks(:sidebar), "sidebar")
pages(:home).publish!(users(:cmsadmin))

pages(:about).add_content_block!(html_blocks(:about_us), "main")
pages(:about).add_content_block!(html_blocks(:sidebar), "sidebar")
pages(:about).publish!(users(:cmsadmin))

create_content_type(:html_block, :name => "HtmlBlock")
create_content_type(:file_block, :name => "FileBlock")
create_content_type(:image_block, :name => "ImageBlock")
create_content_type(:portlet, :name => "Portlet")

create_file_binary_data(:xml, :data => "<root>\n  <data>Test</data>\n</root>\n")
create_file_binary_data(:logo, :data => open(File.join(Rails.root, "public/images/cms/browser_media_logo.png")){|f| f.read})

create_file_metadata(:xml, :file_type => "text/xml", :section => sections(:root), :file_extension => "xml", :file_size => 36, :file_name => "test.xml", :file_binary_data => file_binary_data(:xml))
create_file_metadata(:logo, :file_type => "image/png", :section => sections(:root), :file_extension => "png", :file_size => 2305, :file_name => "logo.png", :file_binary_data => file_binary_data(:logo))

create_file_block(:xml, :name => "XML", :file_metadata => file_metadata(:xml), :updated_by_user => users(:cmsadmin))
create_image_block(:logo, :name => "Logo", :file_metadata => file_metadata(:logo), :updated_by_user => users(:cmsadmin))

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
