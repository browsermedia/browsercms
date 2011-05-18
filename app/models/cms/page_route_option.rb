module Cms
  class PageRouteOption < ActiveRecord::Base
    uses_namespaced_table
    belongs_to :page_route, :class_name => 'Cms::PageRoute'
  end
end