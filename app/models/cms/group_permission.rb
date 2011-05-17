module Cms
class GroupPermission < ActiveRecord::Base
  uses_namespaced_table
  
  belongs_to :group, :class_name => 'Cms::Group'
  belongs_to :permission, :class_name => 'Cms::Permission'
  
  validates_uniqueness_of :permission_id, :scope => :group_id
  
end
end