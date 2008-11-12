class <%= class_name %> < ActiveRecord::Base
<% if attachment_attribute = attributes.detect{|a| a.type == :attachment } %>
  include Attachable
<% end -%>
  acts_as_content_block
<% for attribute in attributes -%>
  <%= 
    case attribute.type
    when :attachment
      "belongs_to :#{attribute.name}"
    when :category, :belongs_to
      "belongs_to :#{attribute.name}"
    end
%>
<% end -%>

<% if attachment_attribute %>
  def set_section
    self.section = Section.first(:conditions => {:name => '<%= class_name.titleize %>'})
  end
  
  def set_<%= attachment_attribute.name %>_file_name
    <%= attachment_attribute.name %>.file_name = "/<%= plural_name %>/#{Time.now.to_s(:year_month_day)}/#{name.to_slug}.#{<%= attachment_attribute.name %>_file.original_filename.split('.').last.to_s.downcase}" if new_record?
  end
<% end -%>

  def render
    buf = ""
<% for attribute in attributes -%>
    <%= 
        case attribute.type 
        when :attachment
          "buf += \"<p><b>#{attribute.name.titleize}:</b> <a href=\\\"\#{#{attribute.name}_link}\\\">\#{#{attribute.name}_path}</a></p>\""
        when :category
          "buf += \"<p><b>#{attribute.name.titleize}:</b> \#{#{attribute.name}.name}</p>\""
        else
          "buf += \"<p><b>#{attribute.name.titleize}:</b> \#{#{attribute.name}}</p>\""
        end 
      %>
<% end %>
  end

end
