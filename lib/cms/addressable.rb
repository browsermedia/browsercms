# Represents any object which exists in a Sitemap.
#
# Can have parents (using SectionNodes) and children.
module Addressable

  # Returns a list of all Addressable objects that are ancestors to this record.
  # @return [Array<Addressable>]
  def ancestors
    ancestor_nodes = node.ancestors
    ancestor_nodes.collect {|node| node.node }
  end
end