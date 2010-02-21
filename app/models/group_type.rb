class GroupType < ActiveRecord::Base
  has_many :groups
  has_many :group_type_permissions
  has_many :permissions, :through => :group_type_permissions

  scope :guest, :conditions => ["group_types.guest = ?", true]
  scope :non_guest, :conditions => ["group_types.guest = ?", false]
  
  scope :cms_access, :conditions => ["group_types.cms_access = ?", true]
  scope :non_cms_access, :conditions => ["group_types.cms_access = ?", false]
  
end
