module Cms
class ContentTypeGroup < ActiveRecord::Base
  has_many :content_types, :order => "content_types.id", :class_name => 'Cms::ContentType'
end
end
