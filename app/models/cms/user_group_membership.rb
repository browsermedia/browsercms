module Cms
  class UserGroupMembership < ActiveRecord::Base
    uses_namespaced_table
    belongs_to :group, :class_name => 'Cms::Group'
    belongs_to :user, :class_name => 'Cms::User'
  end
end