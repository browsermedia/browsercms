module Cms
  class GroupTypePermission < ActiveRecord::Base
    uses_namespaced_table
    belongs_to :group_type, :class_name => 'Cms::GroupType'
    belongs_to :permission, :class_name => 'Cms::Permission'
  end
end