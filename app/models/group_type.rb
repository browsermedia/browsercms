class GroupType < ActiveRecord::Base
  has_many :groups
  has_many :group_type_permissions
  has_many :permissions, :through => :group_type_permissions

  named_scope :guest, :conditions => ["group_types.guest = ?", true]
  named_scope :non_guest, :conditions => ["group_types.guest = ?", false]
  
  def self.cms_accessible
    return GroupType.find_by_name('CMS User').id
  end
end
