class Category < ActiveRecord::Base
  belongs_to :category_type
  belongs_to :parent, :class_name => "Category"
  has_many :children, :class_name => "Category", :foreign_key => "parent_id"
  is_searchable
  validates_presence_of :category_type_id, :name
  validates_uniqueness_of :name, :scope => :category_type_id
  
  named_scope :named, lambda{|name| {:conditions => ['categories.name = ?', name]}}
  
  named_scope :of_type, lambda{|type_name| {:include => :category_type, :conditions => ['category_types.name = ?', type_name], :order => 'categories.name'}}
  named_scope :top_level, :conditions => ['categories.parent_id is null']
  
  named_scope :list, :include => :category_type
  
  def ancestors
    fn = lambda do |cat, parents|
      if cat.parent_id
        p = self.class.find(cat.parent)
        fn.call(p, (parents << p))
      else
        parents.reverse
      end
    end
    fn.call(self, [])
  end
  
  def path(sep=" > ")
    (ancestors.map(&:name) + [name]).join(sep)
  end
  
  def category_type_name
    category_type ? category_type.name : nil
  end
  def self.columns_for_index
    [ {:label => "Name", :method => :name, :order => "categories.name" },
      {:label => "Type", :method => :category_type_name, :order => "category_types.name" },
      {:label => "Updated On", :method => :updated_on_string, :order => "categories.updated_at"}  ]
  end
end
