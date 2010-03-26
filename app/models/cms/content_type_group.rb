class Cms::ContentTypeGroup < ActiveRecord::Base
  namespaces_table
  has_many :content_types, :order => "content_types.id", :class_name => 'Cms::ContentType'
end
