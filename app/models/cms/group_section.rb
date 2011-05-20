module Cms
  class GroupSection < ActiveRecord::Base
    belongs_to :group, :class_name => 'Cms::Group'
    belongs_to :section, :class_name => 'Cms::Section'
  end
end