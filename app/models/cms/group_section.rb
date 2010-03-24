class Cms::GroupSection < ActiveRecord::Base
  belongs_to :group
  belongs_to :section
end
