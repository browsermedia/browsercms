module Cms
  class UserGroupMembership < ActiveRecord::Base

    include Cms::DefaultAccessible

    belongs_to :group, :class_name => 'Cms::Group'
    belongs_to :user, :class_name => 'Cms::User'
  end
end