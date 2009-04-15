class LoadSeedData < ActiveRecord::Migration
  extend Cms::DataLoader
  def self.up
    if %w[development test dev local].include?(Rails.env)
      pwd = "cmsadmin"
    else
      pwd = (0..8).inject(""){|s,i| s << (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).rand}
    end
    User.current = create_user(:cmsadmin, :login => "cmsadmin", :first_name => "CMS", :last_name => "Administrator", :email => "cmsadmin@example.com", :password => pwd, :password_confirmation => pwd)

    create_permission(:administrate, :name => "administrate", :full_name => "Administer CMS" , :description => "Allows users to administer the CMS, including adding users and groups.")
    create_permission(:edit_content, :name => "edit_content", :full_name => "Edit Content" , :description => "Allows users to Add, Edit and Delete both Pages and Blocks. Can Save (but not Publish) and Assign them as well.")
    create_permission(:publish_content, :name => "publish_content", :full_name => "Publish Content" , :description => "Allows users to Save and Publish, Hide and Archive both Pages and Blocks.")

    create_group_type(:guest_group_type, :name => "Guest", :guest => true)
    create_group_type(:registered_public_user, :name => "Registered Public User")
    create_group_type(:cms_user, :name => "CMS User", :cms_access => true)
    group_types(:cms_user).permissions<<permissions(:edit_content)
    group_types(:cms_user).permissions<<permissions(:publish_content)

    create_group(:guest, :name => 'Guest', :code => 'guest', :group_type => group_types(:guest_group_type))
    create_group(:content_admin, :name => 'Cms Administrators', :code => 'cms-admin', :group_type => group_types(:cms_user))
    create_group(:content_editor, :name => 'Content Editors', :code => 'content-editor', :group_type => group_types(:cms_user))
    users(:cmsadmin).groups << groups(:content_admin)
    users(:cmsadmin).groups << groups(:content_editor)

    groups(:content_admin).permissions<<permissions(:administrate)
    groups(:content_editor).permissions<<permissions(:edit_content)
    groups(:content_editor).permissions<<permissions(:publish_content)    
    
    create_site(:default, :name => "Default", :domain => "example.com")
    create_section(:root, :name => "My Site", :path => "/", :root => true)
    create_section(:system, :name => "system", :parent => sections(:root), :path => "/system", :hidden => true)
        
    Group.all.each{|g| g.sections = Section.all }    
    
    create_page(:home, :name => "Home", :path => "/", :section => sections(:root), :template_file_name => "default.html.erb", :cacheable => true)
    create_page(:not_found, :name => "Page Not Found", :path => "/system/not_found", :section => sections(:system), :template_file_name => "default.html.erb", :publish_on_save => true, :hidden => true, :cacheable => true)
    create_page(:access_denied, :name => "Access Denied", :path => "/system/access_denied", :section => sections(:system), :template_file_name => "default.html.erb", :publish_on_save => true, :hidden => true, :cacheable => true)
    create_page(:server_error, :name => "Server Error", :path => "/system/server_error", :section => sections(:system), :template_file_name => "default.html.erb", :publish_on_save => true, :hidden => true, :cacheable => true)

    create_html_block(:page_not_found, :name => "Page Not Found", :content => "<p>The page you tried to access does not exist on this server.</p>", :publish_on_save => true)
    pages(:not_found).create_connector(html_blocks(:page_not_found), "main")
    pages(:not_found).publish!

    create_html_block(:access_denied, :name => "Access Denied", :content => "<p>You have tried to reach a resource or page which you do not have permission to view.</p>", :publish_on_save => true)
    pages(:access_denied).create_connector(html_blocks(:access_denied), "main")
    pages(:access_denied).publish!

    create_html_block(:server_error, :name => "Server Error", :content => "<p>The server encountered an unexpected condition that prevented it from fulfilling the request.</p>", :publish_on_save => true)
    pages(:server_error).create_connector(html_blocks(:server_error), "main")
    pages(:server_error).publish!

    create_page_template(:default, 
      :name => "default", :format => "html", :handler => "erb", 
      :body => <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><%= page_title %></title>
    <%= yield :html_head %>
  </head>
  <body style="margin: 0; padding: 0; text-align: center;">
    <%= cms_toolbar %>
    <div id="wrapper" style="width: 700px; margin: 0 auto; text-align: left; padding: 30px">
      Breadcrumbs: <%= render_breadcrumbs %>
      Main Menu: <%= render_menu %>
      <h1><%= @page_title %></h1>
      <p>BrowserCMS has been installed successfully.</p> 

      <h2>Getting Started</h2>
      <p>To start building your site, you can either <%= link_to "alter this template", edit_cms_page_template_path(PageTemplate.find_by_file_name("default.html.erb")) %> or <%= link_to "create a new one", new_cms_page_template_path %>.  You will be prompted to login with the credentials provided during the install process.  To change which template the pages use, you can click the 'Edit Properties' button above, and choose a different template. After all pages in the site, use the new template, you can safely delete this one.</p>

      <%= container :main %>
    </div>
  </body>
</html>
HTML
    )
    
    pages(:home).publish! 
        
    puts "*************************************************"    
    puts "* YOUR CMS username/password is: cmsadmin/#{pwd}"    
    puts "*************************************************"
        
  end

  def self.down
  end
end
