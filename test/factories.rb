# m is for model, I felt the need to document that for some reason

require File.join(File.dirname(__FILE__), 'support/factory_helpers')
include FactoryHelpers

Factory.define :category, :class => Cms::Category do |m|
  m.association :category_type
  m.sequence(:name) { |n| "TestCategory#{n}" }
end

Factory.define :category_type, :class => Cms::CategoryType do |m|
  m.sequence(:name) { |n| "TestCategoryType#{n}" }
end

Factory.define :connector, :class => Cms::Connector do |m|
  m.association :page
  m.page_version 1
  m.container "main"
  m.association :connectable, :factory => :html_block
  m.connectable_version 1
end

Factory.define :file_block, :class => Cms::FileBlock do |m|
  m.sequence(:name) { |n| "TestFileBlock#{n}" }
  m.attachment_section { find_or_create_root_section }
  m.publish_on_save true
end


Factory.define :group, :class => Cms::Group do |m|
  m.sequence(:name) { |n| "TestGroup#{n}" }
end

Factory.define :cms_user_group, :class=>Cms::Group do |m|
  m.sequence(:name) { |n| "TestGroup#{n}" }
  m.association :group_type, :factory=>:cms_group_type
end

Factory.define :content_editor_group, :parent=>:group do |g|
  g.after_create { |group|
    group.permissions << create_or_find_permission_named("administrate")
    group.permissions << create_or_find_permission_named("edit_content")
    group.permissions << create_or_find_permission_named("publish_content")
  }
end

Factory.define :group_type, :class => Cms::GroupType do |m|
  m.sequence(:name) { |n| "TestGroupType#{n}" }
end

Factory.define :cms_group_type, :class=>Cms::GroupType do |m|
  m.name "CMS User"
  m.cms_access true
end

Factory.define :portlet, :class => DynamicPortlet do |m|
  m.name "Sample Portlet"
end

# Portlets happen to be Non-versioned right now, but this abstracts that in case it changes later.
Factory.define :non_versioned_block, :parent=>:portlet do |m|
end

Factory.define :html_block, :class => Cms::HtmlBlock do |m|
  m.name "About Us"
  m.content "<h1>About Us</h1>\n<p>Lorem ipsum dolor sit amet...</p>"
end

Factory.define :image_block, :class => Cms::ImageBlock do |m|
  m.sequence(:name) { |n| "TestImageBlock#{n}" }
end

Factory.define :link, :class => Cms::Link do |m|
  m.sequence(:name) { |n| "Link #{n}" }
end

Factory.define :page, :class => Cms::Page do |m|
  m.sequence(:name) { |n| "Page #{n}" }
  m.path { |a| "/#{a.name.gsub(/\s/, '_').downcase}" }
  m.template_file_name "default.html.erb"
  m.association :section
end

# TODO: Remove duplication between this and the :page factory.
Factory.define :published_page, :class=>Cms::Page do |m|
  m.sequence(:name) { |n| "Published Page #{n}" }
  m.path { |a| "/#{a.name.gsub(/\s/, '_').downcase}" }
  m.template_file_name "default.html.erb"
  m.association :section
  m.publish_on_save true
end

Factory.define :page_partial, :class => Cms::PagePartial do |m|
  m.sequence(:name) { |n| "_page_partial_#{n}" }
  m.format "html"
  m.handler "erb"
end

Factory.define :page_route, :class => Cms::PageRoute do |m|
  m.sequence(:name) { |n| "Test Route #{n}" }
  m.sequence(:pattern) { |n| "/page_route_#{n}" }
  m.association :page
end

Factory.define :page_template, :class => Cms::PageTemplate do |m|
  m.sequence(:name) { |n| "page_template_#{n}" }
  m.format "html"
  m.handler "erb"
  m.body %q{<html>
  <head>
    <title>
      <%= page_title %>
    </title>
    <%= yield :html_head %>
  </head>
  <body>
    <%= cms_toolbar %>
    <%= container :main %>
  </body>
</html>}
end

Cms::Authoring::PERMISSIONS.each do |p|
  perm_name = "#{p.to_s}_permission".to_sym
  Factory.define perm_name, :class => Cms::Permission do |m|
    m.name p
  end
end

Factory.define :section, :class=>Cms::Section do |m|
  m.name "Test"
  m.path "/test"
  m.parent { find_or_create_root_section }
end

# A publicly accessible (published) page
Factory.define :public_page, :class => Cms::Page do |m|
  m.sequence(:name) { |n| "Page #{n}" }
  m.path { |a| "/#{a.name.gsub(/\s/, '_').downcase}" }
  m.template_file_name "default.html.erb"
  m.association :section, :factory=>:public_section
  m.publish_on_save true
end

Factory.define :public_section, :class=>Cms::Section do |m|
  m.name "Test"
  m.path "/test"
  m.parent { find_or_create_root_section }
  m.after_create { |section|
    section.allow_groups = :all
  }
end

Factory.define :protected_section, :class=>Cms::Section do |m|
  m.name "Protected Section"
  m.path "/protected-section"
  m.parent { find_or_create_root_section }
  m.after_create { |protected_section|
    secret_group = Factory(:group, :name => "Secret")
    secret_group.sections << protected_section
    privileged_user = Factory(:user, :login => "privileged")
    privileged_user.groups << secret_group
  }

end

Factory.define :permission, :class => Cms::Permission do |m|
  m.sequence(:name) { |n| "TestPermission#{n}" }
end

Factory.define :site, :class => Cms::Site do |m|
  m.sequence(:name) { |n| "Test #{n}" }
  m.domain { |a| "#{a.name.gsub(/\s/, "_").downcase}.com" }
end

Factory.define :task, :class => Cms::Task do |m|
  m.association :assigned_by, :factory => :cms_admin
  m.association :assigned_to, :factory => :cms_admin
  m.association :page
end

Factory.define :user, :class => Cms::User do |m|
  m.first_name "Test"
  m.last_name "User"
  m.sequence(:login) { |n| "test_#{n}" }
  m.email { |a| "#{a.login}@example.com" }
  m.password "password"
  m.password_confirmation { |a| a.password }
end

def create_or_find_permission_named(name)
  Cms::Permission.named(name).first || Factory(:permission, :name => name)
end

Factory.define :cms_admin, :parent=>:user do |m|
  m.after_create { |user|
    group = Factory(:group, :group_type => Factory(:group_type, :cms_access => true))
    Cms::Authoring::PERMISSIONS.each do |p|
      group.permissions << create_or_find_permission_named(p)
    end
    user.groups << group
  }
end

Factory.define :content_editor, :parent=>:user do |m|
  m.after_create { |user|
    group = Factory(:group, :group_type => Factory(:group_type, :cms_access => true))
    Cms::Authoring::EDITOR_PERMISSIONS.each do |p|
      group.permissions << create_or_find_permission_named(p)
    end
    user.groups << group
  }
end

Factory.define :content_type_group, :class=>Cms::ContentTypeGroup do |ctg|
  ctg.sequence(:name) { |n| "Group #{n}" }
end

Factory.define :content_type, :class=>Cms::ContentType do |ct|
  ct.association :content_type_group
end

