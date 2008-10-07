class Cms::GroupsController < Cms::ResourceController
  layout 'cms/administration'
  
  protected
    def after_create_url
      index_url
    end
    def after_update_url
      index_url
    end

end