module Cms
  class AbstractFileBlock < ActiveRecord::Base

    set_table_name Namespacing.prefix("file_blocks")

    validates_presence_of :name

    scope :by_section, lambda { |section| {:include => {:attachment => :section_node}, :conditions => ["#{SectionNode.table_name}.section_id = ?", section.id]} }

    def path
      attachment_file_path
    end

    def self.publishable?
      true
    end

  end
end