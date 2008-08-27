class Cms::ConnectorsController < Cms::BaseController
  
  before_filter :load_page, :only => [:new, :create]
  
  def new
    @block_type = params[:block_type] || session[:last_block_type] || 'html_block'
    @container = params[:container]
    @connector = @page.connectors.build(:container => @container)
    @blocks = @block_type.classify.constantize.all(:order => "name")      
  end
  
  def create
    @connector = @page.connectors.build(params[:connector])
    if @connector.save
      redirect_to @page.path
    else
      @blocks = @connector.content_block_type.classify.constantize.all(:order => "name")      
      render :action => 'new'
    end
  end
  
  def destroy
    @connector = Connector.find(params[:id])
    @page = @connector.page
    @content_block = @connector.content_block
    if @connector.destroy
      flash[:notice] = "Removed '#{@content_block.name}' from the '#{@connector.container}' container"
    end
    redirect_to @page.path
  end
  
  private
    def load_page
      @page = Page.find(params[:page_id])
    end
end