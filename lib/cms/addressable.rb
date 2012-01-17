# Represents any object which exists in a Sitemap.
#
# Can have parents (using SectionNodes) and children.
module Addressable

  # Returns a list of all Addressable objects that are ancestors to this record.
  # @return [Array<Addressable]
  def ancestors
    ancestor_nodes = node.ancestors
    ancestor_nodes.collect { |node| node.node }
  end

  # I want to get rid of these in favor of parent and parent_id
  module DeprecatedPageAccessors

    def section_id
      section ? section.id : nil
    end

    def section_id=(sec_id)
      self.section = Section.find(sec_id)
    end

    def section
      section_node ? section_node.section : nil
    end

    def section=(sec)
      if section_node
        section_node.move_to_end(sec)
      else
        build_section_node(:node => self, :section => sec)
      end
    end
  end
end