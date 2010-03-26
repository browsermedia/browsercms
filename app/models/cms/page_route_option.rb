class Cms::PageRouteOption < ActiveRecord::Base
  namespaces_table
  belongs_to :page_route
end
