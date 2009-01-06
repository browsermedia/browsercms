class Cms::PageTemplatesController < Cms::ResourceController
  layout 'cms/administration'
  check_permissions :administrate
  before_filter :set_menu_section
  protected
    def show_url
      index_url
    end
  private
    def set_menu_section
      @menu_section = 'page_templates'
    end


end
