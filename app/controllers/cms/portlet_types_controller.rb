class Cms::PortletTypesController < Cms::ResourceController
  layout 'cms/administration'
  protected
    def show_url
      index_url
    end
end