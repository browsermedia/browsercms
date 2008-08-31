class Section < ActiveRecord::Base
  
  acts_as_nested_set
  
  after_save :move_to_child_of_parent
  
  has_many :pages
    
  def move_to_child_of_parent
    self.move_to_child_of(@section_to_move_to) unless @section_to_move_to.blank?
  end  

  def parent=(section)
    @section_to_move_to = section
  end

  before_destroy :move_children_and_pages_to_parent
  
  def move_children_and_pages_to_parent
    children.each do |section|
      section.parent = self.parent
      section.save!
    end
    pages.each do |page|
      page.section = self.parent
      page.save!
    end    
  end
  
  def move_to_section(section)
    root? ? false : self.move_to_child_of(section)
  end
  
end