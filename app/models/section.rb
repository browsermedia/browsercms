class Section < ActiveRecord::Base
  
  acts_as_list :scope => :parent
  
  belongs_to :parent, :class_name => "Section"
  has_many :children, :class_name => "Section", :foreign_key => "parent_id", :order => "sections.position"
  has_many :pages

  has_many :group_sections
  has_many :groups, :through => :group_sections
  
  named_scope :root, :conditions => ['sections.parent_id is null']
  
  #validates_presence_of :parent_id, :if => Proc.new {root.count > 0}, :message => "section is required"
  
  # Disabling '/' in section name for interoperability with FCKEditor file browser
  validates_format_of :name, :with => /\A[^\/]*\Z/, :message => "cannot contain '/'"
  
  before_destroy :deletable?
  
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
  
  def empty?
    children.count + pages.count == 0
  end
  
  def deletable?
    !root? && empty?
  end
  
  def editable_by_group?(group)
    group.editable_by_section(self)
  end
  
  def self.find_by_name_path(name_path)
    section = Section.root.first
    children = name_path.split("/")[1..-1] || []
    children.each do |name|
      section = section.children.first(:conditions => {:name => name})
    end
    section
  end
  
end