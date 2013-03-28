require 'ancestry'

class Cms::SectionNode < ActiveRecord::Base
  attr_accessible :node, :section, :parent, :node_id, :node_type
  has_ancestry

  # This is the parent section for this node
  # For backwards compatiblity
  def parent_section
    self.parent ? self.parent.node : nil
  end

  alias :section :parent_section

  # For backwards compatiblity
  def section=(new_section)
    self.parent = new_section.node
  end

  # The item this node links to
  belongs_to :node, :polymorphic => :true, :inverse_of => :section_node

  acts_as_list
  # For acts_as_list. Specifies that position should be unique within a section.
  def scope_condition
    ancestry ? "ancestry = '#{ancestry}'" : 'ancestry IS NULL'
  end

  scope :of_type, lambda{|types| {:conditions => ["#{table_name}.node_type IN (?)", types]}}
  scope :in_order, :order => "position asc"
  scope :fetch_nodes, :include => :node

  def visible?
    return false unless node
    return false if (node.respond_to?(:hidden?) && node.hidden?)
    return false if (node.respond_to?(:archived?) && node.archived?)
    return false if (node.respond_to?(:published?) && !node.published?)
    true
  end

  def orphaned?
    !node || (node.class.uses_soft_delete? && node.deleted?)
  end

  #Is this node a section
  def section?
    node_type == 'Cms::Section'
  end

  #Is this node a page
  def page?
    node_type == 'Cms::Page'
  end

  # @param [Section] section
  # @param [Integer] position
  def move_to(section, position)
    #logger.info "Moving Section Node ##{id} to Section ##{sec.id} Position #{pos}"
    transaction do
      if self.parent != section.node
        remove_from_list
        self.parent = section.node
        save
      end
      if position < 0
        position = 0
      else
        #This helps prevent the position from getting out of whack
        #If you pass in a really high number for position, 
        #this just corrects it to the right number
        node_count =Cms::SectionNode.count(:conditions => {:ancestry => ancestry})
        position = node_count if position > node_count
      end
      
      insert_at_position(position)
    end
  end

  def move_before(section_node)
    if section == section_node.section && position < section_node.position
      pos = section_node.position - 1
    else
      pos = section_node.position
    end
    move_to(section_node.section, pos)
  end

  def move_after(section_node)
    if section == section_node.section && position < section_node.position
      pos = section_node.position
    else
      pos = section_node.position + 1
    end
    move_to(section_node.section, pos)
  end

  def move_to_beginning(sec)
    move_to(sec, 0)
  end

  def move_to_end(sec)
    #1.0/0 == Infinity
    move_to(sec, 1.0/0)
  end

  def ancestry_path
    path_ids.join "/"
  end
end
