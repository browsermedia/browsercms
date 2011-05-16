module Cms
class PageRouteOption < ActiveRecord::Base
  namespaces_table
  belongs_to :page_route, :class_name => 'Cms::PageRoute'
end
end