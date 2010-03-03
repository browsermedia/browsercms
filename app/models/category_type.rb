class CategoryType < ActiveRecord::Base
  has_many :categories
  validates_presence_of :name
  validates_uniqueness_of :name
  is_searchable
  named_scope :named, lambda {|name| {:conditions => ['category_types.name = ?', name] } }
  
  # Return a map when the key is category type id as a string
  # and the value is an array of arrays, each entry having 
  # the first value as the category path and the second value
  # being the category id as a string
  def self.category_map
    all.inject(Hash.new([])) do |map, ct| 
      map[ct.id.to_s] = ct.category_list.map{|c| [c.path, c.id.to_s]}
      map
    end
  end
  
  # This is used to get the full list of categories for this category type in the correct order.
  def category_list(order="name")
    list = []
    fn = lambda do |cat|
      list << cat
      cat.children.all(:order => order).each{|c| fn.call(c)}
    end
    categories.top_level.all(:order => order).each{|cat| fn.call(cat)}
    list
  end
  
  def cannot_be_deleted_message
    categories.count.zero? ? nil : I18n.t("models.category_type.cannot_be_deleted", :count => categories.count)
  end
  
  def self.display_name
    I18n.t("models.category_type.display_name")
  end
  
  def self.display_name_plural
     I18n.t("models.category_type.display_name_plural")
  end
  
end
