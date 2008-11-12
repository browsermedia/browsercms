class CategoryType < ActiveRecord::Base
  has_many :categories, :dependent => :delete_all
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
