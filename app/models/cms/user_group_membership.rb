class Cms::UserGroupMembership < ActiveRecord::Base
  namespaces_table
  belongs_to :group
  belongs_to :user
end
