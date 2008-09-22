class FileBlock < AbstractFileBlock

  validates_presence_of :section_id

  acts_as_content_block
  def self.display_name
    "File"
  end

  def render
    #TODO: Escape values
    <<-HTML
      <div id="file_block_#{id}" class="file_block">
        <img src="/images/cms/icons/file_types/#{cms_file.icon}.png" alt=""/> 
        <a href="#{path}">#{name}</a>
        #{cms_file.file_size.round_bytes}
      </div>
    HTML
  end

  def save_file
    unless file.blank?
      self.cms_file = CmsFile.create(:file => file)
    end
  end

end
