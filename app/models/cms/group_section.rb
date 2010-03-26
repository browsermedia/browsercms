class Cms::GroupSection < ActiveRecord::Base
  namespaces_table
  belongs_to :group
  belongs_to :section
end
