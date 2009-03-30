class <%= class_name %> < ActiveRecord::Base
  acts_as_content_block
  <% for attribute in attributes %><%= 
    case attribute.type
    when :attachment
      "belongs_to_attachment\n"
    when :category
      "belongs_to_category\n"
    when :belongs_to
      "belongs_to :#{attribute.name}\n"
    end
%><% end %>

  def renderer(this)
    lambda do
      buf = ""
<% for attribute in attributes -%>
    <%= 
        case attribute.type 
        when :attachment
          "buf += \"<p><b>Attachment:</b> <a href=\\\"\#{this.attachment_link}\\\">\#{this.attachment_file_path}</a></p>\""
        when :category
          "buf += \"<p><b>Category:</b> \#{this.category_name}</p>\""
        else
          "buf += \"<p><b>#{attribute.name.titleize}:</b> \#{this.#{attribute.name}}</p>\""
        end 
      %>
<% end %>
    end
  end

end
