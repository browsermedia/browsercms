class LoadSeedData < ActiveRecord::Migration
  extend Cms::DataLoader
  def self.up
    if Rails.env == "development"
      pwd = "cmsadmin"
    else
      pwd = (0..8).inject(""){|s,i| s << (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).rand}
    end
    create_user(:cmsadmin, :login => "cmsadmin", :first_name => "CMS", :last_name => "Administrator", :email => "cmsadmin@example.com", :password => pwd, :password_confirmation => pwd)

    create_permission(:administrate, :name => "administrate", :full_name => "Administrate CMS" , :description => "Allows users to administer the CMS, including adding users and groups.")
    create_permission(:edit_content, :name => "edit_content", :full_name => "Edit Content" , :description => "Allows users to Add, Edit and Delete both Pages and Blocks. Can Save (but not Publish) and Assign them as well.")
    create_permission(:publish_content, :name => "publish_content", :full_name => "Publish Content" , :description => "Allows users to Save and Publish, Hide and Archive both Pages and Blocks.")

    create_group_type(:guest_group_type, :name => "Guest", :guest => true)
    create_group_type(:registered_public_user, :name => "Registered Public User")
    create_group_type(:search_bot, :name => "Search Bot")
    create_group_type(:cms_user, :name => "CMS User", :cms_access => true)
    group_types(:cms_user).permissions<<permissions(:edit_content)
    group_types(:cms_user).permissions<<permissions(:publish_content)

    create_group(:guest, :name => 'Guest', :code => 'guest', :group_type => group_types(:guest_group_type))
    create_group(:search_bot, :name => 'Search Bot', :code => 'search_bot', :group_type => group_types(:search_bot))
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
        
    groups(:content_editor).sections << Section.all
    groups(:guest).sections << sections(:root)
    groups(:search_bot).sections << sections(:root)
    
    create_page_template(:main, :name => "Main", :file_name => "main", :language => "erb", :body => <<-TEMPLATE)
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><%= @page_title %></title>
    <%= yield :html_head %>
  </head>
  <body style="margin: 0; padding: 0">
    <%= yield %>
    <%= container :main %>
  </body>
</html>
    TEMPLATE
        
    create_page(:home, :name => "Home", :path => "/", :section => sections(:root), :template => page_templates(:main))
    create_page(:not_found, :name => "Not Found", :path => "/system/not_found", :section => sections(:system), :template => page_templates(:main), :publish_on_save => true, :hidden => true)
    create_page(:access_denied, :name => "Access Denied", :path => "/system/access_denied", :section => sections(:system), :template => page_templates(:main), :publish_on_save => true, :hidden => true)
    create_page(:server_error, :name => "Server Error", :path => "/system/server_error", :section => sections(:system), :template => page_templates(:main), :publish_on_save => true, :hidden => true)

    create_html_block(:hello_world, :name => "Hello World", :content => "<h1>Hello, World!</h1>", :publish_on_save => true)

    pages(:home).create_connector(html_blocks(:hello_world), "main")         
    
    pages(:home).publish! 
        
    puts "*************************************************"    
    puts "* YOUR CMS username/password is: cmsadmin/#{pwd}"    
    puts "*************************************************"
        
  end

  def self.down
  end
end
