# m is for model, I felt the need to document that for some reason

Factory.define :connector do |m|
  m.association :page
  m.page_version 1
  m.container "main"
  m.association :connectable, :factory => :html_block
  m.connectable_version 1
end

Factory.define :group do |m|
  m.sequence(:name) {|n| "TestGroup#{n}" }
end

Factory.define :group_type do |m|
  m.sequence(:name) {|n| "TestGroupType#{n}" }
end

Factory.define :html_block do |m|
  m.name "About Us"
  m.content "<h1>About Us</h1>\n<p>Lorem ipsum dolor sit amet...</p>"
end

Factory.define :page do |m|
  m.sequence(:name) {|n| "Page #{n}" }
  m.path {|a| "/#{a.name.gsub(/\s/,'_').downcase}" }
  m.template "Main"
  m.association :section
end

Factory.define :permission do |m|
  m.sequence(:name) {|n| "TestPermission#{n}" }
end

Factory.define :section do |m|
  m.name "Test"
  m.path "/"
  m.parent { Section.root.first }
end

Factory.define :task do |m|
  m.association :assigned_by, :factory => :user
  m.association :assigned_to, :factory => :user
  m.association :page
end

Factory.define :user do |m|
  m.first_name "Test"
  m.last_name "User"
  m.sequence(:login) {|n| "test_#{n}" }
  m.email {|a| "#{a.login}@example.com" }
  m.password "password"
  m.password_confirmation {|a| a.password }
end