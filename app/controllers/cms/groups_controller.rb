class Cms::GroupsController < Cms::ResourceController
  layout 'cms/administration'
  
  check_permissions :administrate  
  
  after_filter :add_default_permissions, :only => [:create]
  after_filter :add_default_sections, :only => [:create]
  
  def index
    #Groups get loaded in the view
    #We're doing this because the new form is on the index page
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
      @object.permissions << Permission.find_by_name('edit_content')
      @object.permissions << Permission.find_by_name('publish_content')
    end

    def add_default_sections
      @object.sections = Section.all
    end

    
end