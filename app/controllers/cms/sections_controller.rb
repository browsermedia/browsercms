class Cms::SectionsController < Cms::BaseController

  before_filter :load_parent, :only => [:new, :create]

  def index
    redirect_to cms_url(:sitemap)
  end

  def show
    redirect_to cms_url(:sitemap)
  end
  
  def new
    @section = @parent.children.build
  end
  
  def create
    @section = @parent.children.build(params[:section])
    if @section.save
      flash[:notice] = "Section '#{@section.name}' was created"
      redirect_to cms_url(@section)
    else
      render :action => 'new'
    end    
  end

  def edit
    @section = Section.find(params[:id])
  end
  
  def update
    @section = Section.find(params[:id])
    if @section.update_attributes(params[:section])
      flash[:notice] = "Section '#{@section.name}' was updated"
      redirect_to cms_url(@section)
    else
      render :action => 'edit'
    end      
  end
  
  def destroy
    @section = Section.find(params[:id])
    @parent = @section.parent
    
    respond_to do |format|
      if @parent && @section.destroy
        flash[:notice] = "Section '#{@section.name}' was deleted"
        format.html { redirect_to cms_url(@parent) }
        format.js {  }
      else
        flash[:error] = "Section '#{@section.name}' cannot be deleted"
        format.html { redirect_to cms_url(@parent) }
        format.js { render :template => 'cms/shared/show_error' }
      end
    end    
  end  
  
  def move
    @section = Section.find(params[:id])
    if params[:section_id]
      @move_to = Section.find(params[:section_id])
    else
      @move_to = Section.root.first
    end
  end
  
  def file_browser              
    @section = Section.find_by_name_path(params[:CurrentFolder])      
    if request.post? && params[:NewFile]
      handle_file_browser_upload
    else
      render_file_browser
    end
  end
  
  protected
    def load_parent
      @parent = Section.find(params[:section_id])
    end

    def handle_file_browser_upload
      begin
        case params[:Type].downcase
        when "file"
          FileBlock.create!(:section => @section, :file => params[:NewFile], :updated_by_user => current_user)
        when "image" 
          ImageBlock.create!(:section => @section, :file => params[:NewFile], :updated_by_user => current_user)
        end
        result = "0"
      rescue Exception => e
        result = "1,'#{escape_javascript(e.message)}'"
      end  
      render :text => %Q{<script type="text/javascript">window.parent.frames['frmUpload'].OnUploadCompleted(#{result});</script>}, :layout => false      
    end
    
    def render_file_browser
      headers['Content-Type'] = "text/xml"
      @files = case params[:Type].downcase
               when "file"
                 FileBlock.by_section(@section)
               when "image" 
                 ImageBlock.by_section(@section)
               else
                 @section.pages
               end
      render :layout => false      
    end

end
