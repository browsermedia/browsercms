class FileBlock < AbstractFileBlock
  include Attachable
  acts_as_content_block
  
  def self.display_name
    "File"
  end

  def render
    #TODO: Escape values
    <<-HTML
      <div id="file_block_#{id}" class="file_block">
        <img src="/images/cms/icons/file_types/#{attachment.icon}.png" alt=""/>
        <a href="#{path}">#{name}</a>
        #{attachment.file_size.round_bytes}
      </div>
    HTML
  end

  

end
