class SectionNode < ActiveRecord::Base
  belongs_to :section
  belongs_to :node, :polymorphic => :true

  acts_as_list :scope => :section

  #Is this node a section
  def section?
    node_type == 'Section'
  end

  #Is this node a page
  def page?
    node_type == 'Page'
  end
  
  def move_to(sec, pos)
    transaction do
      if section != sec
        remove_from_list
        self.section = sec
        save
      end
      
      #This helps prevent the position from getting out of whack
      #If you pass in a really high number for position, 
      #this just corrects it to the right number
      node_count = SectionNode.count(:conditions => {:section_id => section_id})
      pos = node_count if pos > node_count
      
      insert_at_position(pos)
    end
  end
  
  def move_to_end(sec)
    #1.0/0 == Infinity
    move_to(sec, 1.0/0)
  end
  
end
