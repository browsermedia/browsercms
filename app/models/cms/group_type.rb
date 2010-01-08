class GroupType < ActiveRecord::Base
  has_many :groups
  has_many :group_type_permissions
  has_many :permissions, :through => :group_type_permissions

  named_scope :guest, :conditions => ["group_types.guest = ?", true]
  named_scope :non_guest, :conditions => ["group_types.guest = ?", false]
  
  named_scope :cms_access, :conditions => ["group_types.cms_access = ?", true]
  named_scope :non_cms_access, :conditions => ["group_types.cms_access = ?", false]
  
end
