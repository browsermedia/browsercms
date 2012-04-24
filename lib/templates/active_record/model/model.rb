<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
<% attributes.select {|attr| attr.reference? }.each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
<% # These are BrowserCMS specific extensions to the model generator. -%>
<% attributes.select {|attr| attr.type == :category }.each do |attribute| -%>
  belongs_to_category
<% end -%>
<% attributes.select {|attr| attr.type == :attachment }.each do |attribute| -%>
  has_attachment :<%= attribute.name %>
<% end -%>
<% attributes.select {|attr| attr.type == :attachments }.each do |attribute| -%>
  has_many_attachments :<%= attribute.name %>
<% end -%>
end
<% end -%>