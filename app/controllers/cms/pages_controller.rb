class Cms::PagesController < Cms::BaseController
  
  skip_before_filter :login_required, :only => [:show]
  before_filter :load_section, :only => [:new, :create]

  def show
    if params[:path]
      set_page_mode
      @path = "/#{params[:path].join("/")}"
      @page = Page.find_by_path(@path)
      raise ActiveRecord::RecordNotFound.new("No page at '#{@path}'") unless @page    
    else
      @page = Page.find(params[:id])
    end
    render :layout => @page.layout
  end

  def new
    @page = @section.pages.build
  end

  def edit
    @page = Page.find(params[:id])
  end

  def create
    @page = @section.pages.build(params[:page])
    if @page.save
      flash[:notice] = "Page was '#{@page.name}' created."
      redirect_to([:cms, @page])
    else
      render :action => "new"
    end
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(params[:page])
      flash[:notice] = "Page was '#{@page.name}' updated."
      redirect_to([:cms, @page])
    else
      render :action => "edit"
    end
  end

  def destroy
    @page = Page.find(params[:id])
    if @page.destroy
      flash[:notice] = "Page was '#{@page.name}' deleted."
    end
    redirect_to(cms_pages_url)
  end
  
  private
  
    def load_section
      @section = Section.find(params[:section_id])
    end
  
    def set_page_mode
      @mode = params[:mode] || session[:page_mode] || "view"
      session[:page_mode] = @mode      
    end
  
end
