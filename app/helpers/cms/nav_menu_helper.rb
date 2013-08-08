module Cms
  module NavMenuHelper
    extend ActiveSupport::Concern

    included do
      helper_method :new_button_path, :target_section
    end

    # In most cases, the 'New' button should go to create a new page.
    def new_button_path
      cms.new_section_page_path(target_section)
    end

    # Used to determine which section a New Page should go in, based on the current context.
    def target_section
      if @page && @page.parent
        @page.parent
      else
        Cms::Section.first
      end
    end
  end
end