class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :permissions
  
  validates_presence_of :name
end
