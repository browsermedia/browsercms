class Page < ActiveRecord::Base
  version_fu do
    belongs_to :author, :class_name=>'::Author'
  end
  
  belongs_to :author
  belongs_to :creator, :class_name=>'Author'
end