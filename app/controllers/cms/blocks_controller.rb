class Cms::BlocksController < Cms::BaseController

  layout 'cms/content_library'

  before_filter :load_model, :only => [:show, :show_version, :edit, :revisions, :destroy, :publish, :archive, :revert_to]

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
      if @block.connected_page.blank?
        redirect_to_first params[:_redirect_to], cms_url(@block)
      else
        redirect_to @block.connected_page.path        
      end
    else
      render :template => new_template
    end
  end
  
  def show
    render :template => show_template
  end
  
  def show_version
    if params[:version]
      @block = @block.as_of_version(params[:version])
    end
    render :template => show_template
  end
  
  def edit
    render :template => edit_template    
  end
  
  def update
    @block = model.find(params[:id])
    if @block.update_attributes(params[model_name])
      flash[:notice] = "#{block_type.titleize} '#{@block.name}' was updated"
      redirect_to_first params[:_redirect_to], cms_url(@block)
    else
      render :template => edit_template
    end    
  end
  
  def destroy
    do_command(:destroy, "deleted")
    redirect_to_first params[:_redirect_to], cms_content_library_url
  end
 
  def publish
    do_command(:publish, "published")
    redirect_to cms_url(@block) 
  end
  
  def archive
    do_command(:archive, "archived")
    redirect_to cms_url(@block)
  end
  
  def revert_to
    begin
      @block.revert_to(params[:version])
      flash[:notice] = "Reverted '#{@block.name}' to version #{params[:version]}"
    rescue Exception => e
      flash[:error] = "Could not revert '#{@block.name}': #{e}"
    end
    redirect_to cms_url(@block)
  end
    
  protected
    def load_model
      @block = model.find(params[:id])
    end
  
    def do_command (cmd, result)
      if @block.send(cmd)
        flash[:notice] = "#{block_type.titleize} '#{@block.name}' was #{result}"
      else
        flash[:error] = "#{block_type.titleize} '#{@block.name}' could not be #{result}"
      end
    end
    
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