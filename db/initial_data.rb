# Load up data that was created in load seed data migration
cmsadmin = User.first(:conditions => {:login => 'cmsadmin'})
root_section = Section.root.first
home_page = Page.first(:conditions => {:name => "Home"})

# Now create the additional initial data
create_section(:products, :name => "Products", :parent => root_section, :path => "/products")
create_section(:browsercms, :name => "BrowserCMS", :parent => sections(:products), :path => "/browsercms")
create_section(:browserams, :name => "BrowserAMS", :parent => sections(:products), :path => "/browserams")
create_section(:about, :name => "About", :parent => sections(:root), :path => "/about")
create_section(:people, :name => "People", :parent => sections(:about), :path => "/people")
create_section(:careers, :name => "Careers", :parent => sections(:about), :path => "/careers")

cmsadmin.groups.each{|g| g.sections << Section.all }

create_page_template(:two_column, :name => "Two Column", :file_name => "two_column", :language => "erb", :body=> <<-TEMPLATE)
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><%= @page_title %></title>
    <%= yield :html_head %>
  </head>
  <body style="margin: 0; padding: 0">
    <%= yield %>
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

create_page(:about, :name => "About Us", :path => "/about", :section => sections(:about), :template => page_templates(:two_column), :updated_by_user => cmsadmin)
create_page(:kerry, :name => "Kerry Gunther", :path => "/people/kerry", :section => sections(:people), :template => page_templates(:two_column), :updated_by_user => cmsadmin)
create_page(:pat, :name => "Patrick Peak", :path => "/people/pat", :section => sections(:people), :template => page_templates(:two_column), :updated_by_user => cmsadmin)
create_page(:paul, :name => "Paul Barry", :path => "/people/paul", :section => sections(:people), :template => page_templates(:two_column), :updated_by_user => cmsadmin)

create_page(:test, :name => "Test", :path => "/test", :section => sections(:root), :template => page_templates(:main), :updated_by_user => cmsadmin)
create_html_block(:test, :name => "Test", :connect_to_page_id => pages(:test).id, :connect_to_container => "main", :updated_by_user => cmsadmin)
pages(:test).publish!(cmsadmin)

create_html_block(:sidebar, :name => "Sidebar", :content => "<ul><li><a href=\"/\">Home</a></li><li><a href=\"/about\">About Us</a></li></ul>", :publish_on_save => true, :updated_by_user => cmsadmin)
create_html_block(:about_us, :name => "About Us", :content => "We are super fantastic", :publish_on_save => true, :updated_by_user => cmsadmin)

home_page.add_content_block!(html_blocks(:sidebar), "sidebar")
home_page.publish!(cmsadmin)

pages(:about).add_content_block!(html_blocks(:about_us), "main")
pages(:about).add_content_block!(html_blocks(:sidebar), "sidebar")
pages(:about).publish!(cmsadmin)

create_attachment_file(:xml, :data => "<root>\n  <data>Test</data>\n</root>\n")
create_attachment_file(:logo, :data => open(File.join(Rails.root, "public/images/cms/browser_media_logo.png")){|f| f.read})

create_attachment(:xml, :file_type => "text/xml", :section => sections(:root), :file_extension => "xml", :file_size => 36, :file_name => "test.xml", :attachment_file => attachment_files(:xml))
create_attachment(:logo, :file_type => "image/png", :section => sections(:root), :file_extension => "png", :file_size => 2305, :file_name => "logo.png", :attachment_file => attachment_files(:logo))

create_file_block(:xml, :name => "XML", :attachment => attachments(:xml), :updated_by_user => cmsadmin, :publish_on_save => true)
create_image_block(:logo, :name => "Logo", :attachment => attachments(:logo), :updated_by_user => cmsadmin, :publish_on_save => true)

create_dynamic_portlet(:recently_updated_pages,
  :name => 'Recently Updated Pages',  
  :code => "@pages = Page.all(:order => 'updated_at desc', :limit => 3)",
  :template => <<-TEMPLATE
<h2>Recent Updates</h2>
<ul>
  <% @pages.each do |page| %><li>
    <%= page.name %>
  </li><% end %>
</ul>
TEMPLATE
)
