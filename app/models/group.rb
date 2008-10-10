class Group < ActiveRecord::Base
  
  has_many :user_group_memberships
  has_many :users, :through => :user_group_memberships
  
  has_many :group_permissions
  has_many :permissions, :through => :group_permissions
  
  has_many :group_sections
  has_many :sections, :through => :group_sections
    
  validates_presence_of :name
  
end
