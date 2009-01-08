class <%= class_name %> < ActiveRecord::Base
  acts_as_content_block <% if attachment_attribute = attributes.detect{|a| a.type == :attachment } %>:belongs_to_attachment<% end %>
<% for attribute in attributes -%>
  <%= 
    case attribute.type
    when :category, :belongs_to
      "belongs_to :#{attribute.name}"
    end
  %>
<% end -%>

  def renderer(this)
    lambda do
      buf = ""
<% for attribute in attributes -%>
    <%= 
        case attribute.type 
        when :attachment
          "buf += \"<p><b>#{attribute.name.titleize}:</b> <a href=\\\"\#{this.#{attribute.name}_link}\\\">\#{this.#{attribute.name}_path}</a></p>\""
        when :category
          "buf += \"<p><b>#{attribute.name.titleize}:</b> \#{this.#{attribute.name}.name}</p>\""
        else
          "buf += \"<p><b>#{attribute.name.titleize}:</b> \#{this.#{attribute.name}}</p>\""
        end 
      %>
<% end %>
    end
  end

end
