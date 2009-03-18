module Cms
  module Extensions
    module ActionView
      module Base
        def next_tabindex
          @tabindex ||= 0
          @tabindex += 1
        end
      end
    end
  end
end
ActionView::Base.send(:include, Cms::Extensions::ActionView::Base)