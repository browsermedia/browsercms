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

end
