class Cms::GroupType < ActiveRecord::Base
  namespaces_table
  has_many :groups, :class_name => 'Cms::Group'
  has_many :group_type_permissions, :class_name => 'Cms::GroupTypePermission'
  has_many :permissions, :through => :group_type_permissions , :class_name => 'Cms::Permission'

  named_scope :guest, :conditions => ["#{GroupType.table_name}.guest = ?", true]
  named_scope :non_guest, :conditions => ["#{GroupType.table_name}.guest = ?", false]
  
  named_scope :cms_access, :conditions => ["#{GroupType.table_name}.cms_access = ?", true]
  named_scope :non_cms_access, :conditions => ["#{GroupType.table_name}.cms_access = ?", false]
  
end
