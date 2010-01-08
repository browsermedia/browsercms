class GroupPermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :permission
  
  validates_uniqueness_of :permission_id, :scope => :group_id
  
end