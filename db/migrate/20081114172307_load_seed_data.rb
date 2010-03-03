class LoadSeedData < ActiveRecord::Migration
  extend Cms::DataLoader
  def self.up
    if %w[development test dev local].include?(Rails.env)
      pwd = "cmsadmin"
    else
      pwd = (0..8).inject(""){|s,i| s << (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).rand}
    end
    User.current = create_user(:cmsadmin, :login => "cmsadmin", :first_name => "CMS", :last_name => "Administrator", :email => "cmsadmin@example.com", :password => pwd, :password_confirmation => pwd)

    create_permission(:administrate, :name => "administrate", :full_name => I18n.t("seed.administrate_full_name") , :description => I18n.t("seed.administrate_description"))
    create_permission(:edit_content, :name => "edit_content", :full_name => I18n.t("seed.edit_full_name") , :description => I18n.t("seed.edit_description"))
    create_permission(:publish_content, :name => "publish_content", :full_name => I18n.t("seed.publish_full_name") , :description => I18n.t("seed.publish_description"))

    create_group_type(:guest_group_type, :name => I18n.t("seed.guest"), :guest => true)
    create_group_type(:registered_public_user, :name => I18n.t("seed.registered_public_user"))
    create_group_type(:cms_user, :name => I18n.t("seed.cms_user"), :cms_access => true)
    group_types(:cms_user).permissions<<permissions(:edit_content)
    group_types(:cms_user).permissions<<permissions(:publish_content)

    create_group(:guest, :name => I18n.t("seed.guest"), :code => 'guest', :group_type => group_types(:guest_group_type))
    create_group(:content_admin, :name => I18n.t("seed.cms_admin"), :code => 'cms-admin', :group_type => group_types(:cms_user))
    create_group(:content_editor, :name => I18n.t("seed.content_editors"), :code => 'content-editor', :group_type => group_types(:cms_user))
    users(:cmsadmin).groups << groups(:content_admin)
    users(:cmsadmin).groups << groups(:content_editor)

    groups(:content_admin).permissions<<permissions(:administrate)
    groups(:content_editor).permissions<<permissions(:edit_content)
    groups(:content_editor).permissions<<permissions(:publish_content)    
    
    create_site(:default, :name => I18n.t("seed.default"), :domain => "example.com")
    create_section(:root, :name => I18n.t("seed.my_site"), :path => "/", :root => true)
    create_section(:system, :name => I18n.t("seed.system"), :parent => sections(:root), :path => "/system", :hidden => true)
        
    Group.all.each{|g| g.sections = Section.all }    
    
    create_page(:home, :name => I18n.t("seed.home"), :path => "/", :section => sections(:root), :template_file_name => "default.html.erb", :cacheable => true)
    create_page(:not_found, :name => I18n.t("seed.page_not_found"), :path => "/system/not_found", :section => sections(:system), :template_file_name => "default.html.erb", :publish_on_save => true, :hidden => true, :cacheable => true)
    create_page(:access_denied, :name => I18n.t("seed.access_denied"), :path => "/system/access_denied", :section => sections(:system), :template_file_name => "default.html.erb", :publish_on_save => true, :hidden => true, :cacheable => true)
    create_page(:server_error, :name => I18n.t("seed.server_error"), :path => "/system/server_error", :section => sections(:system), :template_file_name => "default.html.erb", :publish_on_save => true, :hidden => true, :cacheable => true)

    create_html_block(:page_not_found, :name => I18n.t("seed.page_not_found"), :content => "<p>#{I18n.t("seed.page_not_found_content")}</p>", :publish_on_save => true)
    pages(:not_found).create_connector(html_blocks(:page_not_found), "main")
    pages(:not_found).publish!

    create_html_block(:access_denied, :name => I18n.t("seed.access_denied"), :content => "<p>#{I18n.t("seed.access_denied_content")}</p>", :publish_on_save => true)
    pages(:access_denied).create_connector(html_blocks(:access_denied), "main")
    pages(:access_denied).publish!

    create_html_block(:server_error, :name => I18n.t("seed.server_error"), :content => "<p>#{I18n.t("seed.server_error_content")}</p>", :publish_on_save => true)
    pages(:server_error).create_connector(html_blocks(:server_error), "main")
    pages(:server_error).publish!
    pages(:home).publish! 
        
    puts "*************************************************"    
    puts "* YOUR CMS username/password is: cmsadmin/#{pwd}"    
    puts "*************************************************"
        
  end

  def self.down
  end
end
