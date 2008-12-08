class Tag < ActiveRecord::Base
  has_many :taggings
end
