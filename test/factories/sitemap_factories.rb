Factory.define :root_section, :class=>Section do |m|
  m.name "Root"
  m.path "/"
  m.root true
end

Factory.define :public_section, :class=>Section do |m|
  m.sequence(:name) {|n| "Public Section #{n}"}
  m.sequence(:path) {|n| "/public-section-#{n}"}
  m.association :parent, :factory=>:root_section
  # Doesn't yet have permissions for all groups (todo)
end

Factory.define :public_page, :class=>Page do |m|
  m.sequence(:name) {|n| "Public Page #{n}"}
  m.sequence(:path) {|n| "/public-page-#{n}"}
  m.association :section, :factory=>:public_section
end
