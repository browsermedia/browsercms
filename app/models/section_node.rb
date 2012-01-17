class SectionNode < ActiveRecord::Base
  has_ancestry

  # This is the parent section for this node
  #belongs_to :section
  def section
    self.parent.node
  end

  def section=(new_section)
    self.parent = new_section.node
  end

  # The item this node links to
  belongs_to :node, :polymorphic => :true

  acts_as_list :scope => 'ancestry'

  named_scope :of_type, lambda{|types| {:conditions => ["section_nodes.node_type IN (?)", types]}}

  def visible?
    return false unless node
    return false if(node.respond_to?(:hidden?) && node.hidden?)
    return false if(node.respond_to?(:archived?) && node.archived?)
    return false if(node.respond_to?(:published?) && !node.published?)
    true
  end

  def orphaned?
    !node || (node.class.uses_soft_delete? && node.deleted?)
  end

  #Is this node a section
  def section?
    node_type == 'Section'
  end

  #Is this node a page
  def page?
    node_type == 'Page'
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
        node_count = SectionNode.count(:conditions => {:ancestry => ancestry})
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
  
  def ancestors()
    ancestors = []
    fn = lambda do |sn|
      ancestors << sn.section
      if sn.section && !sn.section.root?
        fn.call(sn.section.node)
      end
    end
    fn.call(self)
    ancestors.reverse
  end
end
