require File.join(File.dirname(__FILE__), '../support/factory_helpers')
include FactoryHelpers

FactoryGirl.define do
  factory :category, :class => Cms::Category do |m|
    m.association :category_type
    m.sequence(:name) { |n| "TestCategory#{n}" }
  end

  factory :root_section, :class => Cms::Section do |m|
    m.name "My Site"
    m.path "/"
    m.root true
    m.groups { Cms::Group.all }
  end

  factory :category_type, :class => Cms::CategoryType do |m|
    m.sequence(:name) { |n| "TestCategoryType#{n}" }
  end

  factory :connector, :class => Cms::Connector do |m|
    m.association :page
    m.page_version 1
    m.container "main"
    m.association :connectable, :factory => :html_block
    m.connectable_version 1
  end

# Duplication between :file_block and :image_block
  factory :image_block, :class => Cms::ImageBlock do |m|
    ignore do
      parent { find_or_create_root_section }
      attachment_file { mock_file }
      attachment_file_path { name }
    end
    m.sequence(:name) { |n| "TestImageBlock#{n}" }
    m.after(:build) { |f, evaluator|
      f.attachments.build(:data => evaluator.attachment_file, :attachment_name => 'file', :parent => evaluator.parent, :data_file_path => evaluator.attachment_file_path)
    }
    m.publish_on_save true
  end

  factory :file_block, :class => Cms::FileBlock do |m|
    ignore do
      parent { find_or_create_root_section }
      attachment_file { mock_file(:original_filename => 'sample_upload.txt') }
      attachment_file_path { name }
    end
    m.sequence(:name) { |n| "TestFileBlock#{n}" }
    m.after(:build) { |f, evaluator|
      f.attachments.build(:data => evaluator.attachment_file, :attachment_name => 'file', :parent => evaluator.parent, :data_file_path => evaluator.attachment_file_path)
    }
    m.publish_on_save true

  end

  factory :group, :class => Cms::Group do |m|
    m.sequence(:name) { |n| "TestGroup#{n}" }
  end

  factory :cms_user_group, :class => Cms::Group do |m|
    m.sequence(:name) { |n| "TestGroup#{n}" }
    m.association :group_type, :factory => :cms_group_type
  end

  factory :content_editor_group, :parent => :group do |g|
    g.after(:create) { |group|
      group.permissions << create_or_find_permission_named("administrate")
      group.permissions << create_or_find_permission_named("edit_content")
      group.permissions << create_or_find_permission_named("publish_content")
    }
  end

  factory :group_type, :class => Cms::GroupType do |m|
    m.sequence(:name) { |n| "TestGroupType#{n}" }
  end

  factory :cms_group_type, :class => Cms::GroupType do |m|
    m.name "CMS User"
    m.cms_access true
  end

  factory :portlet, :class => DynamicPortlet do |m|
    m.name "Sample Portlet"
  end

# Portlets happen to be Non-versioned right now, but this abstracts that in case it changes later.
  factory :non_versioned_block, :parent => :portlet do |m|
  end

  factory :html_block, :class => Cms::HtmlBlock do |m|
    m.name "About Us"
    m.content "<h1>About Us</h1>\n<p>Lorem ipsum dolor sit amet...</p>"
  end

  factory :link, :class => Cms::Link do |m|
    m.association :section
    m.sequence(:name) { |n| "Link #{n}" }
    m.publish_on_save true
  end

  factory :page, :class => Cms::Page do |m|
    m.sequence(:name) { |n| "Page #{n}" }
    m.path { |a| "/#{a.name.gsub(/\s/, '_').downcase}" }
    m.template_file_name "default.html.erb"
    m.association :section
  end


  factory :page_partial, :class => Cms::PagePartial do |m|
    m.sequence(:name) { |n| "_page_partial_#{n}" }
    m.format "html"
    m.handler "erb"
    m.body "Nonblank"
  end

  factory :page_route, :class => Cms::PageRoute do |m|
    m.sequence(:name) { |n| "Test Route #{n}" }
    m.sequence(:pattern) { |n| "/page_route_#{n}" }
    m.association :page
  end

  factory :page_template, :class => Cms::PageTemplate do |m|
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
    <%= container :main %>
  </body>
</html>}
  end

  Cms::Authoring::PERMISSIONS.each do |p|
    perm_name = "#{p.to_s}_permission".to_sym
    factory perm_name, :class => Cms::Permission do |m|
      m.name p
    end
  end

  factory :section, :class => Cms::Section do |m|
    m.name "Test"
    m.path "/test"
    m.parent { find_or_create_root_section }
  end


# A publicly accessible (published) page
  factory :public_page, :class => Cms::Page do |m|
    m.sequence(:name) { |n| "Page #{n}" }
    m.path { |a| "/#{a.name.gsub(/\s/, '_').downcase}" }
    m.template_file_name "default.html.erb"
    m.association :section, :factory => :public_section
    m.publish_on_save true
  end

  factory :public_section, :class => Cms::Section do |m|
    m.name "Test"
    m.path "/test"
    m.parent { find_or_create_root_section }
    m.after(:create) { |section|
      section.allow_groups = :all
    }
  end

  factory :protected_section, :class => Cms::Section do |m|
    m.name "Protected Section"
    m.path "/protected-section"
    m.parent { find_or_create_root_section }
    m.after(:create) { |protected_section|
      secret_group = FactoryGirl.create(:group, :name => "Secret")
      secret_group.sections << protected_section
      privileged_user = FactoryGirl.create(:user, :login => "privileged")
      privileged_user.groups << secret_group
    }

  end

  factory :permission, :class => Cms::Permission do |m|
    m.sequence(:name) { |n| "TestPermission#{n}" }
  end

  factory :site, :class => Cms::Site do |m|
    m.sequence(:name) { |n| "Test #{n}" }
    m.domain { |a| "#{a.name.gsub(/\s/, "_").downcase}.com" }
  end

  factory :task, :class => Cms::Task do |m|
    m.association :assigned_by, :factory => :cms_admin
    m.association :assigned_to, :factory => :cms_admin
    m.association :page
  end

  factory :user, :class => Cms::User do |m|
    m.first_name "Test"
    m.last_name "User"
    m.sequence(:login) { |n| "test_#{n}" }
    m.email { |a| "#{a.login}@example.com" }
    m.password "password"
    m.password_confirmation { |a| a.password }
  end

# Represents a user who has actually created an account on the site.
  factory :registered_user, :parent => :user do |u|
    u.after(:create) { |user|
      user.groups << Cms::Group.guest
    }
  end

  factory :disabled_user, parent: :user do |u|
    u.after(:create) { |user|
      user.disable!
    }
  end

  factory :cms_admin, :parent => :user do |m|
    m.after(:create) { |user|
      group = FactoryGirl.create(:group, :group_type => FactoryGirl.create(:group_type, :cms_access => true))
      Cms::Authoring::PERMISSIONS.each do |p|
        group.permissions << create_or_find_permission_named(p)
      end
      user.groups << group
    }
  end

  factory :content_editor, :parent => :user do |m|
    m.after(:create) { |user|
      group = FactoryGirl.create(:group, :group_type => FactoryGirl.create(:group_type, :cms_access => true))
      Cms::Authoring::EDITOR_PERMISSIONS.each do |p|
        group.permissions << create_or_find_permission_named(p)
      end
      user.groups << group
    }
  end

  factory :content_type_group, :class => Cms::ContentTypeGroup do |ctg|
    ctg.sequence(:name) { |n| "Group #{n}" }
  end

  factory :content_type, :class => Cms::ContentType do |ct|
    ct.association :content_type_group
  end

  # This is just for CMS testing
  factory :portlet_with_helper, :class => UsesHelperPortlet do |portlet|
    ignore do
      page_path "/random"
    end
    portlet.name "ProductCatalog"
    portlet.after(:create) do |content, evaluator|
      page = FactoryGirl.create(:public_page, path: evaluator.page_path)
      page.add_content(content)
      page.publish!
    end
  end

  factory :product, :class => Product do |product|
    product.name "Product"
    product.sequence(:slug) { |n| "/product-#{n}" }
  end
end
