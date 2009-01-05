class FileBlock < AbstractFileBlock

  acts_as_content_block :belongs_to_attachment => true, :taggable => true
  
  def self.display_name
    "File"
  end

  def renderer(file_block)
    lambda do
      <<-HTML
        <div id="file_block_#{file_block.id}" class="file_block">
          <img src="/images/cms/icons/file_types/#{file_block.attachment.icon}.png" alt="#{h(file_block.attachment.icon)}"/>
          #{link_to(file_block.name, file_block.attachment_link)}
          #{file_block.attachment.file_size.round_bytes}
        </div>
      HTML
    end
  end

  

end
