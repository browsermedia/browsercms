class Cms::PortletTypesController < Cms::ResourceController
  layout 'cms/administration'
  check_permissions :administrate
  protected
    def show_url
      index_url
    end
end