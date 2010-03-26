class Cms::GroupTypePermission < ActiveRecord::Base
  namespaces_table
  belongs_to :group_type
  belongs_to :permission
end
