module Cms
  class Category < ActiveRecord::Base
    belongs_to :category_type, :class_name => 'Cms::CategoryType'
    belongs_to :parent, :class_name => 'Cms::Category'
    has_many :children, :class_name => 'Cms::Category', :foreign_key => "parent_id"
    is_searchable

    include DefaultAccessible

    attr_accessible :category_type

    validates_presence_of :category_type_id, :name
    validates_uniqueness_of :name, :scope => :category_type_id

    scope :named, lambda { |name| {:conditions => ["#{table_name}.name = ?", name]} }
    scope :of_type, lambda { |type_name| {:include => :category_type, :conditions => ["#{CategoryType.table_name}.name = ?", type_name], :order => "#{Category.table_name}.name"} }
    scope :top_level, :conditions => ["#{Category.table_name}.parent_id is null"]
    scope :list, :include => :category_type

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
      [{:label => "Name", :method => :name, :order => "#{Category.table_name}.name"},
       {:label => "Type", :method => :category_type_name, :order => "#{CategoryType.table_name}.name"},
       {:label => "Updated On", :method => :updated_on_string, :order => "#{Category.table_name}.updated_at"}]
    end
  end
end