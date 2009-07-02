class Section < ActiveRecord::Base

  flush_cache_on_change
  
  #The node that links this section to its parent
  has_one :node, :class_name => "SectionNode", :as => :node
  
  #The nodes that link this section to its children
  has_many :child_nodes, :class_name => "SectionNode"
  has_many :child_sections, :class_name => "SectionNode", :conditions => ["node_type = ?", "Section"], :order => 'section_nodes.position'

  has_many :pages, :through => :child_nodes, :source => :node, :source_type => 'Page', :order => 'section_nodes.position'
  has_many :sections, :through => :child_nodes, :source => :node, :source_type => 'Section', :order => 'section_nodes.position'

  has_many :group_sections
  has_many :groups, :through => :group_sections
  
  named_scope :root, :conditions => ['root = ?', true]
  named_scope :system, :conditions => {:name => 'system'}
  
  named_scope :hidden, :conditions => {:hidden => true}
  named_scope :not_hidden, :conditions => {:hidden => false}
  
  named_scope :named, lambda{|name| {:conditions => ['sections.name = ?', name]}}
  named_scope :with_path, lambda{|path| {:conditions => ['sections.path = ?', path]}}
  
  validates_presence_of :name, :path
  #validates_presence_of :parent_id, :if => Proc.new {root.count > 0}, :message => "section is required"
  
  # Disabling '/' in section name for interoperability with FCKEditor file browser
  validates_format_of :name, :with => /\A[^\/]*\Z/, :message => "cannot contain '/'"
  
  validate :path_not_reserved
  
  before_destroy :deletable?
  
  attr_accessor :full_path
  
  def visible_child_nodes(options={})
    children = child_nodes.of_type(["Section", "Page", "Link"]).all(:order => 'section_nodes.position')
    visible_children = children.select{|sn| sn.visible?}
    options[:limit] ? visible_children[0...options[:limit]] : visible_children
  end
  
  def all_children_with_name
    child_sections.map do |s|
      if s.node
        s.node.full_path = root? ? s.node.name : "#{name} / #{s.node.name}"
        [s.node] << s.node.all_children_with_name
      end
    end.flatten.compact
  end
  
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
  
  def ancestors(options={})
    ancs = node ? node.ancestors : []
    options[:include_self] ? ancs + [self] : ancs
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
    child_nodes.reject{|n| n.orphaned?}.empty?
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
  def first_page_or_link
    section_node = child_nodes.of_type(['Link','Page']).first(:order => "section_nodes.position")
    return section_node.node if section_node
    sections.each do |s| 
      node = s.first_page_or_link
      return node if node
    end
    nil
  end
    
  def actual_path
    if root?
      "/"
    else
      p = first_page_or_link
      p ? p.path : "#"
    end
  end  
  
  def path_not_reserved
    if Cms.reserved_paths.include?(path)
      errors.add(:path, "is invalid, '#{path}' a reserved path")
    end
  end
      
end