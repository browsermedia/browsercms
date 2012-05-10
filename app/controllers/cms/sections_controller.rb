class Cms::SectionsController < Cms::BaseController

  before_filter :load_parent, :only => [:new, :create]
  before_filter :load_section, :only => [:edit, :update, :destroy, :move]
  before_filter :set_toolbar_tab
  
  helper_method :public_groups
  helper_method :cms_groups

  def index
    redirect_to cms.sitemap_path
  end

  def show
    redirect_to cms.sitemap_path
  end
  
  def new
    @section = @parent.build_section
    @section.groups = @parent.groups
  end
  
  def create
    @section = Cms::Section.new(params[:section])
    @section.parent = @parent
    @section.groups = @section.parent.groups unless cms_current_user.able_to?(:administrate)
    if @section.save
      flash[:notice] = "Section '#{@section.name}' was created"
      redirect_to @section
    else
      render :action => 'new'
    end    
  end

  def edit
  end
  
  def update
    params[:section].delete('group_ids') if params[:section] &&  !cms_current_user.able_to?(:administrate)
    @section.attributes = params[:section]
    if @section.save
      flash[:notice] = "Section '#{@section.name}' was updated"
      redirect_to @section
    else
      render :action => 'edit'
    end      
  end
  
  def destroy
    respond_to do |format|
      if @section.deletable? && @section.destroy
        message = "Section '#{@section.name}' was deleted."
        format.html { flash[:notice] = message; redirect_to(sitemap_url) }
        format.json { render :json => {:success => true, :message => message } }
      else
        message = "Section '#{@section.name}' could not be deleted"
        format.html { flash[:error] = message; redirect_to(sitemap_url) }
        format.json { render :json => {:success => false, :message => message } }
      end
    end
  end  
  
  def move
    if params[:section_id]
      @move_to = Section.find(params[:section_id])
    else
      @move_to = Section.root.first
    end
  end
  
  def file_browser              
    @section = Cms::Section.find_by_name_path(params[:CurrentFolder])
    if request.post? && params[:NewFile]
      handle_file_browser_upload
    else
      render_file_browser
    end
  end
  
  protected
    def load_parent
      @parent = Cms::Section.find(params[:section_id])
      raise Cms::Errors::AccessDenied unless cms_current_user.able_to_edit?(@parent)
    end

    def load_section
      @section = Cms::Section.find(params[:id])
      raise Cms::Errors::AccessDenied unless cms_current_user.able_to_edit?(@section)
    end

    def handle_file_browser_upload
      begin
        case params[:Type].downcase
        when "file"
          FileBlock.create!(:section => @section, :file => params[:NewFile])
        when "image" 
          ImageBlock.create!(:section => @section, :file => params[:NewFile])
        end
        result = "0"
      rescue Exception => e
        result = "1,'#{escape_javascript(e.message)}'"
      end  
      render :text => %Q{<script type="text/javascript">window.parent.frames['frmUpload'].OnUploadCompleted(#{result});</script>}, :layout => false      
    end
    
    def render_file_browser
      @files = case params[:Type].downcase
               when "file"
                 FileBlock.by_section(@section)
               when "image" 
                 ImageBlock.by_section(@section)
               else
                 @section.pages
               end
       render 'cms/sections/file_browser.xml.builder', :layout => false
    end

    def public_groups
      @public_groups ||= Cms::Group.public.all(:order => "#{Cms::Group.table_name}.name")
    end

    def cms_groups
      @cms_groups ||= Cms::Group.cms_access.all(:order => "#{Cms::Group.table_name}.name")
    end

    def set_toolbar_tab
      @toolbar_tab = :sitemap
    end
end
