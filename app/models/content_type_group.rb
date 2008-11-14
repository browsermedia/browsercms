class ContentTypeGroup < ActiveRecord::Base
  has_many :content_types, :order => "content_types.id"
end
