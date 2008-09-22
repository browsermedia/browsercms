class Cms::BlocksController < Cms::BaseController

  layout 'cms/content_library'

  before_filter :load_block, :only => [:show, :show_version, :edit, :revisions, :destroy, :publish, :archive, :revert_to, :update]

  helper_method :model_name

  def index
    @blocks = model.find(:all, :order => "name")
  end

  def new
    @content_type = ContentType.find_by_key(model_name)
    @block = @content_type.new_content(params[model_name])
    render :template => @content_type.template_for_new, :layout => 'cms/application'
  end
  
  def create
    @block = model.new(params[model_name])
    if @block.save
      flash[:notice] = "#{model_name.titleize} '#{@block.name}' was created"
      if @block.connected_page.blank?
        redirect_to_first params[:_redirect_to], cms_url(@block)
      else
        redirect_to @block.connected_page.path        
      end
    else
      render :action => "new"
    end
  end
  
  def show_version
    if params[:version]
      @block = @block.as_of_version(params[:version])
    end
  end
  
  def update
    if @block.update_attributes(params[model_name])
      flash[:notice] = "#{model_name.titleize} '#{@block.name}' was updated"
      redirect_to_first params[:_redirect_to], cms_url(@block)
    else
      render :action => "edit"
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
    def load_block
      @block = model.find(params[:id])
    end
  
    def do_command (cmd, result)
      if @block.send(cmd)
        flash[:notice] = "#{model_name.titleize} '#{@block.name}' was #{result}"
      else
        flash[:error] = "#{model_name.titleize} '#{@block.name}' could not be #{result}"
      end
    end
  
    def model_name
      @model_name ||= begin
        if params[:block_type].blank?
          session[:last_block_type] ||= 'html_block'
        else
          session[:last_block_type] = params[:block_type].singularize
        end  
      end
    end
  
    def model
      @model ||= model_name.classify.constantize
    end
    
end