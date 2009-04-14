class <%= class_name %> < ActiveRecord::Base
  acts_as_content_block
  <% for attribute in attributes %><%= 
    case attribute.type
    when :attachment
      %Q{belongs_to_attachment
        
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
        end}
    when :category
      "belongs_to_category\n"
    when :belongs_to
      "belongs_to :#{attribute.name}\n"
    end
%><% end %>

end
