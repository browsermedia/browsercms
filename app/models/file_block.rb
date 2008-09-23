class FileBlock < AbstractFileBlock

  acts_as_content_block
  before_save :save_file
  
  def self.display_name
    "File"
  end

  def render
    #TODO: Escape values
    <<-HTML
      <div id="file_block_#{id}" class="file_block">
        <img src="/images/cms/icons/file_types/#{file_metadata.icon}.png" alt=""/>
        <a href="#{path}">#{name}</a>
        #{file_metadata.file_size.round_bytes}
      </div>
    HTML
  end

  

end
