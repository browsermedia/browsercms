module Cms
  class PageRouteOption < ActiveRecord::Base
    belongs_to :page_route, :class_name => 'Cms::PageRoute'

    extend DefaultAccessible
  end
end