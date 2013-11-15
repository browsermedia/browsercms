module Cms
  class AbstractFileBlock < ActiveRecord::Base
    self.table_name = "cms_file_blocks"

    def self.with_parent_id(parent_id)
      if parent_id == 'all'
        where(true) # Empty scope for chaining
      else
        self.includes({:attachments => :section_node})
            .references(:section_node)
            .where(["#{"cms_section_nodes"}.ancestry = ?",  Section.find(parent_id).ancestry_path])

      end
    end

    validates_presence_of :name

    # Return the parent section for this block.
    # @return [Cms::Section]
    def parent
      file.parent
    end

    # Exists here so FileBrowser can polymorphically call file_size on Page, Images, Files, etc.
    def file_size
      file.size.round_bytes
    end

    def path
      file.url
    end

    def self.publishable?
      true
    end

    def set_attachment_path
      if @attachment_file_path && @attachment_file_path != attachment.file_path
        attachment.file_path = @attachment_file_path
      end
    end

    def set_attachment_section
      if @attachment_section_id && @attachment_section_id != attachment.section
        attachment.section_id = @attachment_section_id
      end
    end

  end
end