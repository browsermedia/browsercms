class Cms::LinksController < Cms::BaseController

  before_filter :load_section, :only => [:new, :create, :move_to]
  
  def new
    @link = Link.new(:section => @section)
  end

  def create
    @link = Link.new(params[:link])
    @link.section = @section
    if @link.save
      flash[:notice] = "Link was '#{@link.name}' created."
      redirect_to cms_url(@section)
    else
      render :action => "new"
    end
  end

  def edit
    @link = Link.find(params[:id])
  end
  
  def update
    @link = Link.find(params[:id])
    if @link.update_attributes(params[:link])
      flash[:notice] = "Link '#{@link.name}' was updated"
      redirect_to cms_url(@link.section || :sitemap)
    else
      render :action => 'edit'
    end      
  end
  
  def destroy
    respond_to do |format|
      if @link.destroy
        flash[:notice] = "Link '#{@link.name}' was deleted."
        format.html { redirect_to cms_url(:sitemap) }
        format.js { }
      else
        flash[:error] = "Link '#{@link.name}' could not be deleted"
        format.html { redirect_to cms_url(:sitemap) }
        format.js { render :template => 'cms/shared/show_error' }
      end
    end
    
  end

  protected

    def load_section
      @section = Section.find(params[:section_id])
    end

end
