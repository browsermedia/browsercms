class Section < ActiveRecord::Base
  belongs_to :parent, :class_name => "Section"
  has_many :children, :class_name => "Section", :foreign_key => "parent_id"
  has_many :pages
  
  named_scope :root, :conditions => ['sections.parent_id is null']
  
  validates_presence_of :parent_id, :if => Proc.new {root.count > 0}, :message => "Parent section is required"
  
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
  
  def root?
    parent_id.nil?
  end
  
  def move_to(section)
    if root?
      false
    else
      self.parent = section
      save
    end
  end
  
end