class Cms::ConnectorsController < Cms::BaseController
  
  before_filter :load_page, :only => [:new, :create]
  
  def new    
    @block_type = ContentType.find_by_key(params[:block_type] || session[:last_block_type] || 'html_block')
    @container = params[:container]
    @connector = @page.connectors.build(:container => @container)
    @blocks = @block_type.model_class.all(:order => "name")      
  end

  def create
    @block_type = ContentType.find_by_key(params[:content_block_type])
    raise "Unknown block type" unless @block_type
    @block = @block_type.model_class.find(params[:content_block_id])
    if @page.add_content_block!(@block, params[:container])
      redirect_to @page.path
    else
      @blocks = @block_type.model_class.all(:order => "name")      
      render :action => 'new'
    end
  end
  
  def destroy
    @connector = Connector.find(params[:id])
    @page = @connector.page
    @content_block = @connector.content_block
    if @page.destroy_connector(@connector)
      flash[:notice] = "Removed '#{@content_block.name}' from the '#{@connector.container}' container"
    else
      flash[:error] = "Failed to remove '#{@content_block.name}' from the '#{@connector.container}' container"
    end
    redirect_to @page.path
  end

  { #Define actions for moving connectors around
    :move_up => "up in",
    :move_down => "down in",
    :move_to_top => "to the top of",
    :move_to_bottom => "to the bottom of"    
  }.each do |move, where|
    define_method move do
      @connector = Connector.find(params[:id])
      @page = @connector.page
      @content_block = @connector.content_block
      if @connector.send(move)
        flash[:notice] = "Moved '#{@content_block.name}' #{where} the '#{@connector.container}' container"
      else
        flash[:error] = "Failed to move '#{@content_block.name}' #{where} the '#{@connector.container}' container"
      end
      redirect_to @page.path    
    end
  end

  def usages
    @content_type = ContentType.find_by_key(params[:block_type])
    @block = @content_type.model_class.find(params[:id])
    @connectors = Connector.for_block(@block)

    render :layout => 'cms/content_library'
  end

  private
    def load_page
      @page = Page.find(params[:page_id])
    end
end