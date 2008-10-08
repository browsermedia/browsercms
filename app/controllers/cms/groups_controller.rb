class Cms::GroupsController < Cms::ResourceController
  layout 'cms/administration'
  
  after_filter :update_permissions, :only => [:update]
  
  protected
    def after_create_url
      index_url
    end
    def after_update_url
      index_url
    end

    def update_permissions
      @object.permission_ids = params[:permission_ids]     
    end
end