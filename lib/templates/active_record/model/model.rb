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
  belongs_to_attachment

  def set_attachment_file_path
    # The default behavior is use /attachments/file.txt for the attachment path,
    # assuming file.txt was the name of the file the user uploaded
    # You should override this with your own strategy for setting the attachment path
    super
  end

  def set_attachment_section
    # The default behavior is to put all attachments in the root section
    # Override this method if you would like to change that
    super
  end
<% end -%>
end
<% end -%>