class <%= class_name %> < ActiveRecord::Base
  acts_as_content_block
<% for attribute in attributes -%>
  <%= 
    case attribute.type
    when :category, :belongs_to
      "belongs_to :#{attribute.name}"
    end
%>
<% end -%>
end
