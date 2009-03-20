class Cms::GroupsController < Cms::ResourceController
  layout 'cms/administration'
  
  check_permissions :administrate  
  
  before_filter :set_menu_section
  after_filter :add_default_permissions, :only => [:create]
  after_filter :add_default_sections, :only => [:create]
  
  def index
    @groups = Group.paginate(
      :include => :group_type,
      :page => params[:page], 
      :order => params[:order] || "groups.name")
  end
  
  protected
    def after_create_url
      index_url
    end
    def after_update_url
      index_url
    end
    
    #The group has been created and we add these permissions to it
    def add_default_permissions
      #TODO: These shouldn't be hard-coded here, 
      #these values should be stored in the database to make them easy to change
      if @object.cms_access?
        @object.permissions << Permission.find_by_name('edit_content')
        @object.permissions << Permission.find_by_name('publish_content')
      end
    end

    def add_default_sections
      @object.sections = Section.all
    end

    def set_menu_section
      @menu_section = 'groups'
    end
    
end
