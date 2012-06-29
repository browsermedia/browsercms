module Cms
  class RedirectsController < Cms::ResourceController
    include Cms::AdminTab
    check_permissions :administrate

    def new_button_path
      new_redirect_path
    end

    protected
    def show_url
      index_url
    end

    def order_by_column
      "from_path, to_path"
    end

    private
    def set_menu_section
      @menu_section = 'redirects'
    end

  end
end