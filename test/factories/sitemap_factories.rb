Factory.define :root_section, :class=>Section do |m|
  m.name "My Site"
  m.path "/"
  m.root true
  m.groups { Group.all }
end

Factory.define :public_section, :class=>Section do |m|
  m.sequence(:name) { |n| "Public Section #{n}" }
  m.sequence(:path) { |n| "/public-section-#{n}" }
  m.association :parent, :factory=>:root_section
  m.groups { Group.all }
end

Factory.define :public_page, :class=>Page do |m|
  m.sequence(:name) { |n| "Public Page #{n}" }
  m.sequence(:path) { |n| "/public-page-#{n}" }
  m.association :section, :factory=>:public_section
  m.publish_on_save true
end

Factory.define :content_editor, :class=>User do |m|
  m.sequence(:login) { |n| "test_#{n}" }
  m.email { |a| "#{a.login}@example.com" }
  m.password "password"
  m.password_confirmation { |a| a.password }
  m.groups { Group.all }
end