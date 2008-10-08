class Cms::GroupsController < Cms::ResourceController
  layout 'cms/administration'
  
  after_filter :update_permissions, :only => :update
  after_filter :add_permissions, :only => :create
  
  def index
    # Look up in the view instead of here.
  end
  
  protected
    def after_create_url
      index_url
    end
    def after_update_url
      index_url
    end

    def add_permissions
      @object.permissions << [Permission.find_by_name("editor"), Permission.find_by_name("publish-page")]
    end

    def update_permissions
      @object.permission_ids = params[:permission_ids]     
    end
end