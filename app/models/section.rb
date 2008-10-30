class Section < ActiveRecord::Base
  
  #The node that links this section to its parent
  has_one :node, :class_name => "SectionNode", :as => :node
  
  #The nodes that link this section to its children
  has_many :child_nodes, :class_name => "SectionNode"

  has_many :pages, :through => :child_nodes, :source => :node, :source_type => 'Page', :order => 'section_nodes.position'
  has_many :sections, :through => :child_nodes, :source => :node, :source_type => 'Section', :order => 'section_nodes.position'

  has_many :group_sections
  has_many :groups, :through => :group_sections
  
  named_scope :root, :conditions => ['root = ?', true]
  
  
  #validates_presence_of :parent_id, :if => Proc.new {root.count > 0}, :message => "section is required"
  
  # Disabling '/' in section name for interoperability with FCKEditor file browser
  validates_format_of :name, :with => /\A[^\/]*\Z/, :message => "cannot contain '/'"
  
  before_destroy :deletable?
  
  def parent_id
    parent ? parent.id : nil
  end
  
  def parent
    node ? node.section : nil
  end
  
  def parent_id=(sec_id)
    self.parent = Section.find(sec_id)
  end
  
  def parent=(sec)
    if node
      node.move_to_end(sec)
    else
      build_node(:node => self, :section => sec)
    end      
  end  
  
  def ancestors
    node ? node.ancestors : []
  end
  
  def move_to(section)
    if root?
      false
    else
      node.move_to_end(section)
    end
  end
  
  def public?
    !!(groups.find_by_code('guest'))
  end
  
  def empty?
    child_nodes.count == 0
  end
  
  def deletable?
    !root? && empty?
  end
  
  def editable_by_group?(group)
    group.editable_by_section(self)
  end
  
  def status
    public? ? :unlocked : :locked
  end
  
  def self.find_by_name_path(name_path)
    section = Section.root.first
    children = name_path.split("/")[1..-1] || []
    children.each do |name|
      section = section.sections.first(:conditions => {:name => name})
    end
    section
  end
  
  #The first page that is a decendent of this section
  def first_page
    page = pages.not_archived.first 
    return page if page
    sections.each do |s| 
      page = s.first_page
      return page if page
    end
    nil
  end
  
end