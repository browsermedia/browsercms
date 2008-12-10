class Cms::BlocksController < Cms::BaseController

  layout 'cms/content_library'

  before_filter :load_block, :only => [:show, :show_version, :edit, :destroy, :publish, :archive, :revert_to, :update]

  helper_method :content_type_name

  def index
    if params[:section_id] && params[:section_id] != 'all'
      @blocks = model_class.search(params[:search]).paginate(:page => params[:page], :include => { :attachment => { :section_node => :section }}, :conditions => ["sections.id = ?", params[:section_id]])
    else
      @blocks = model_class.search(params[:search]).paginate(:page => params[:page])
    end
  end

  def new
    @block = model_class.new(params[model_class.name.underscore])
    if @last_block = model_class.last
      @block.category = @last_block.category if @block.respond_to?(:category=)
    end
    render :layout => 'cms/application'
  end

  def create
    @block = model_class.new(params[model_name])
    if @block.save!
      flash[:notice] = "#{content_type.display_name} '#{@block.name}' was created"
      if @block.connected_page
        redirect_to @block.connected_page.path
      else
        redirect_to_first params[:_redirect_to], cms_url(:blocks, content_type.name.underscore.pluralize)
      end
    else
      render :action => 'new', :layout => 'cms/application'
    end
  end

  def show_version
    if params[:version]
      @block = @block.as_of_version(params[:version])
    end
    render :action => 'show'
  end

  def revisions
    if model_class.versioned?
      load_block
    else
      render :text => "Not Implemented", :status => :not_implemented
    end
  end

  def edit
    render :layout => 'cms/application'
  end
  
  def update
    attrs = params[model_class.name.underscore]
    if @block.update_attributes(attrs)
      flash[:notice] = "#{content_type_name.titleize} '#{@block.name}' was updated"
      redirect_to_first params[:_redirect_to], cms_url(:blocks, @block.class.name.underscore, :show, @block)
    else
      render :action => "edit", :layout => 'cms/application'
    end
  rescue ActiveRecord::StaleObjectError => e
    @other_version = @block.class.find(@block.id) 
    render :action => "edit"
  end

  def destroy
    do_command("deleted") { @block.destroy }
    redirect_to_first params[:_redirect_to], cms_content_library_url
  end

  def publish
    do_command("published") { @block.publish! }
    redirect_to cms_url(@block)
  end

  def archive
    do_command("archived") { @block.archive }
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

    def content_type_name
      @conten_type_name ||= begin
        if params[:block_type].blank?
          session[:last_block_type] ||= 'html_block'
        else
          session[:last_block_type] = params[:block_type].singularize
        end
      end
    end

    def content_type
      @content_type ||= ContentType.find_by_key(content_type_name)
    end

    def model_class
      content_type.model_class
    end

    def model_name
      model_class.name.underscore      
    end

    def load_block
      @block = model_class.find(params[:id])
    end

    def do_command(result)
      if yield
        flash[:notice] = "#{content_type_name.titleize} '#{@block.name}' was #{result}"
      else
        flash[:error] = "#{content_type_name.titleize} '#{@block.name}' could not be #{result}"
      end
    end



end