class Permission < ActiveRecord::Base
  has_many :group_permissions
  has_many :groups, :through => :group_permissions
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  named_scope :named, lambda{|name| {:conditions => {:name => name}}}
  
end
