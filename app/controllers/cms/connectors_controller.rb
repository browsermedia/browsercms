class Cms::ConnectorsController < Cms::BaseController
  
  before_filter :set_toolbar_tab
  before_filter :load_page, :only => [:new, :create]
  
  def new    
    @block_type = ContentType.find_by_key(params[:block_type] || session[:last_block_type] || 'html_block')
    @container = params[:container]
    @connector = @page.connectors.build(:container => @container)
    @blocks = @block_type.model_class.all(:order => "name", :conditions => ["deleted = ?", false])      
  end

  def create
    @block_type = ContentType.find_by_key(params[:connectable_type])
    raise "Unknown block type" unless @block_type
    @block = @block_type.model_class.find(params[:connectable_id])
    if @page.create_connector(@block, params[:container])
      redirect_to @page.path
    else
      @blocks = @block_type.model_class.all(:order => "name")      
      render :action => 'new'
    end
  end
  
  def destroy
    @connector = Connector.find(params[:id])
    @page = @connector.page
    @connectable = @connector.connectable
    if @page.remove_connector(@connector)
      flash[:notice] = I18n.t("controllers.connectors.removed", :connectable_name => @connectable.name, :container => @connector.container)
    else
      flash[:error] = I18n.t("controllers.connectors.faliled_to_remove", :connectable_name => @connectable.name, :container => @connector.container)
    end
    redirect_to @page.path
  end

  { #Define actions for moving connectors around
    :up => I18n.t("controllers.connectors.up_in"),
    :down => I18n.t("controllers.connectors.up_in"),
    :to_top => I18n.t("controllers.connectors.up_in"),
    :to_bottom => I18n.t("controllers.connectors.up_in")    
  }.each do |move, where|
    define_method "move_#{move}" do
      @connector = Connector.find(params[:id])
      @page = @connector.page
      @connectable = @connector.connectable
      if @page.send("move_connector_#{move}", @connector)
        flash[:notice] = I18n.t("controllers.connectors.moved", :connectable_name => @connectable.name, :where => where, :container => @connector.container)
      else
        flash[:error] = I18n.t("controllers.connectors.failed_to_move", :connectable_name => @connectable.name, :where => where, :container => @connector.container)
      end
      redirect_to @page.path    
    end
  end

  private
    def load_page
      @page = Page.find(params[:page_id])
    end
    def set_toolbar_tab
      @toolbar_tab = :content_library
    end
end
