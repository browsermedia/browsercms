module Cms
  class GroupTypePermission < ActiveRecord::Base
    belongs_to :group_type, :class_name => 'Cms::GroupType'
    belongs_to :permission, :class_name => 'Cms::Permission'

    include DefaultAccessible
  end
end