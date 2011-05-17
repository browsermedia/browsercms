module Cms
class GroupSection < ActiveRecord::Base
  uses_namespaced_table
  belongs_to :group, :class_name => 'Cms::Group'
  belongs_to :section, :class_name => 'Cms::Section'
end
end