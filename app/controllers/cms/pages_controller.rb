class Cms::PagesController < Cms::BaseController
  
  skip_before_filter :login_required, :only => [:show, :foo]
  before_filter :load_section, :only => [:new, :create, :move_to]
  before_filter :load_page, :only => [:edit, :revisions, :move_to, :destroy]
  before_filter :hide_toolbar, :only => [:new, :create, :move_to]

  verify :method => :put, :only => [:move_to]

  def show
    if !params[:id].blank?
      redirect_to Page.find(params[:id]).path
    elsif params[:path].nil?
      raise ActiveRecord::RecordNotFound.new("Page could not be found")
    else
      @path = "/#{params[:path].join("/")}"

      @file = File.join(ActionController::Base.cache_store.cache_path, @path)

      if is_not_root_path? && File.exists?(@file)
        send_file(@file, 
          :type => Mime::Type.lookup_by_extension(@file.split(/\./).last.to_s.downcase).to_s,
          :disposition => false #see monkey patch in lib/action_controller/streaming.rb
        ) 
        return
      end
      
      set_page_mode
      @page = Page.find_by_path(@path)
      if @page
        render :layout => @page.layout
      else
        if redirect = Redirect.find_by_from_path(@path)
          redirect_to redirect.to_path
        else
          raise ActiveRecord::RecordNotFound.new("No page at '#{@path}'") unless @page    
        end
      end
    end
  end

  def new
    @page = @section.pages.build
  end

  def create
    @page = @section.pages.build(params[:page])
    if @page.save
      flash[:notice] = "Page was '#{@page.name}' created."
      redirect_to cms_url(@page)
    else
      render :action => "new"
    end
  end

  def update
    @page = Page.find(params[:id])
    #@page.status = params[:status] || "IN_PROGRESS"
    if @page.update_attributes(params[:page])
      flash[:notice] = "Page was '#{@page.name}' updated."
      redirect_to cms_url(@page)
    else
      render :action => "edit"
    end
  end

  def destroy
    respond_to do |format|
      if @page.destroy
        flash[:notice] = "Page '#{@page.name}' was deleted."
        format.html { redirect_to cms_url(:sitemap) }
        format.js { }
      else
        flash[:error] = "Page '#{@page.name}' could not be deleted"
        format.html { redirect_to cms_url(:sitemap) }
        format.js { render :template => 'cms/shared/show_error' }
      end
    end
    
  end
  
  #status actions
  {:publish => "Published", :hide => "Hidden", :archive => "Archived"}.each do |status, verb|
    define_method status do
      load_page
      if @page.send(status)
        flash[:notice] = "Page '#{@page.name}' was '#{verb}'."
      end
      redirect_to @page.path
    end
  end
  
  def move_to
    if @page.move_to(@section)
      flash[:notice] = "Page '#{@page.name}' was moved to '#{@section.name}'."
    end
    
    respond_to do |format|
      format.html { redirect_to cms_path(@section, :page_id => @page) }
      format.js { render :template => 'cms/shared/show_notice' }
    end    
  end
  
  private

    def load_page
      @page = Page.find(params[:id])
    end
  
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

    def is_not_root_path?
      params[:path] != []
    end
  
end
