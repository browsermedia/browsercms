class CategoryType < ActiveRecord::Base
  has_many :categories, :dependent => :delete_all
  validates_presence_of :name
  validates_uniqueness_of :name
  
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
  def category_list
    list = []
    fn = lambda do |cat|
      list << cat
      cat.children.all(:order => "name").each{|c| fn.call(c)}
    end
    categories.top_level.all(:order => "name").each{|cat| fn.call(cat)}
    list
  end
  
end
