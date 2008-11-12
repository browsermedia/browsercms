class Category < ActiveRecord::Base
  belongs_to :category_type
  validates_presence_of :category_type_id
  
  named_scope :of_type, lambda{|type_name| {:include => :category_type, :conditions => ['category_types.name = ?', type_name], :order => 'categories.name'}}
  
  def category_type_name
    category_type ? category_type.name : nil
  end
  def self.columns_for_index
    [{:label => "Type", :method => :category_type_name }]
  end
end
