class GroupTypePermission < ActiveRecord::Base
  belongs_to :group_type
  belongs_to :permission
end