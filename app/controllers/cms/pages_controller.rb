class Cms::PagesController < Cms::BaseController
  
  skip_before_filter :login_required, :only => [:show]
  before_filter :load_section, :only => [:new, :create, :move_to]
  before_filter :hide_toolbar, :only => [:new, :create, :move_to]

  def show
    if !params[:id].blank?
      redirect_to Page.find(params[:id]).path
    elsif params[:path].nil?
      raise ActiveRecord::RecordNotFound.new("Page could not be found")
    else
      set_page_mode
      @path = "/#{params[:path].join("/")}"
      @page = Page.find_by_path(@path)
      raise ActiveRecord::RecordNotFound.new("No page at '#{@path}'") unless @page    
      render :layout => @page.layout
    end
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
  
  #status actions
  {:publish => "Published", :hide => "Hidden", :archive => "Archived"}.each do |status, verb|
    define_method status do
      @page = Page.find(params[:id])
      if @page.send(status)
        flash[:notice] = "Page '#{@page.name}' was '#{verb}'."
      end
      redirect_to @page.path
    end
  end
  
  def move
    @page = Page.find(params[:id])
    if params[:section_id]
      @section = Section.find(params[:section_id])
    else
      @section = Section.root.first
    end
  end
  
  def move_to
    @page = Page.find(params[:id])
    if @page.move_to(@section)
      flash[:notice] = "Page '#{@page.name}' was moved to '#{@section.name}'."
    end
    
    respond_to do |format|
      format.html { redirect_to [:cms, @section] }
      format.js { render :template => 'cms/shared/show_notice' }
    end    
  end
  
  private
  
    def load_section
      @section = Section.find(params[:section_id])
    end
  
    def set_page_mode
      @mode = params[:mode] || session[:page_mode] || "view"
      session[:page_mode] = @mode      
    end
  
    def hide_toolbar
      @hide_page_toolbar = true
    end
  
end
