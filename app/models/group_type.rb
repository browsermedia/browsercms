class GroupType < ActiveRecord::Base
  has_many :groups
  has_many :group_type_permissions
  has_many :permissions, :through => :group_type_permissions
  
  def self.cms_accessible
    return GroupType.find_by_name('CMS User').id
  end
end
