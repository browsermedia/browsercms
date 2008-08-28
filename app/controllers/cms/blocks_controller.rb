class Cms::BlocksController < Cms::BaseController

  layout 'cms/content_library'

  helper_method :model_name

  def index
    @blocks = model.find(:all, :order => "name")
    render :template => index_template
  end

  def new
    @block = model.new(params[model_name])
    render :template => new_template
  end
  
  def create
    @block = model.new(params[model_name])
    if @block.save
      flash[:notice] = "#{block_type.titleize} '#{@block.name}' was created"
      if @block.connected_page
        redirect_to @block.connected_page.path
      else
        redirect_to_first params[:_redirect_to], [:cms, @block]
      end
    else
      render :template => new_template
    end
  end
  
  def show
    @block = model.find(params[:id])
    render :template => show_template
  end
  
  def edit
    @block = model.find(params[:id])
    render :template => edit_template    
  end
  
  def update
    @block = model.find(params[:id])
    if @block.update_attributes(params[model_name])
      flash[:notice] = "#{block_type.titleize} '#{@block.name}' was updated"
      redirect_to_first params[:_redirect_to], [:cms, @block]
    else
      render :template => edit_template
    end    
  end
  
  def destroy
    @block = model.find(params[:id])
    if @block.destroy
      flash[:notice] = "#{block_type.titelize} '#{@block.name}' was deleted"
    else
      flash[:error] = "#{block_type.titleize} '#{@block.name}' could not be deleted"
    end
    redirect_to_first params[:_redirect_to], cms_content_library_url
  end
  
  protected
  
    def block_type
      controller_name.singularize
    end
  
    def model_name
      @model_name ||= begin
        if block_type == 'block'
          session[:last_block_type] = params[:block_type] ? params[:block_type] : (session[:last_block_type] || 'html_block')
        else
          session[:last_block_type] = block_type
        end  
      end
    end
  
    def model
      @model ||= model_name.classify.constantize
    end  
    
    def index_template; 'cms/blocks/index' end
    def new_template; 'cms/blocks/new' end
    def edit_template; 'cms/blocks/edit' end
    def show_template; 'cms/blocks/show' end
    
end