module Cms

  # Any controller that is considered to be on the 'Admin' tab should include this.
  module AdminTab
    extend ActiveSupport::Concern

    included do
      before_filter :set_menu_section
    end

    def new_button_path
      cms.new_user_path
    end
  end
end