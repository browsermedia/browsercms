module Cms
class UserGroupMembership < ActiveRecord::Base
  namespaces_table
  belongs_to :group, :class_name => 'Cms::Group'
  belongs_to :user, :class_name => 'Cms::User'
end
end