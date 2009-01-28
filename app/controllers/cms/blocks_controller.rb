class Cms::BlocksController < Cms::BaseController

  layout :determine_layout

  before_filter :load_block, :only => [:show, :show_version, :edit, :destroy, :publish, :archive, :revert_to, :update]
  before_filter :set_toolbar_tab


  helper_method :content_type_name

  def index
    options = {}
    if params[:section_id] && params[:section_id] != 'all'
      options[:include] = { :attachment => { :section_node => :section }} 
      options[:conditions] = ["sections.id = ?", params[:section_id]]
    end
    options[:page] = params[:page]    
    options[:order] = model_class.default_order if model_class.respond_to?(:default_order)
    @blocks = model_class.searchable? ? model_class.search(params[:search]).paginate(options) : model_class.paginate(options)
  end

  def new
    @block = model_class.new(params[model_class.name.underscore])
    if @last_block = model_class.last
      @block.category = @last_block.category if @block.respond_to?(:category=)
    end
  end

  def create
    @block = model_class.new(params[model_name])
    if @block.save
      flash[:notice] = "#{content_type.display_name} '#{@block.name}' was created"
      if !params[:thickbox].blank?
        render :text => "<html><head><script type='text/javascript'>self.parent.location.reload()</script></head><body></body></html>"
      elsif model_class.connectable? && @block.connected_page
        redirect_to @block.connected_page.path
      else
        redirect_to_first params[:_redirect_to], cms_url(:blocks, content_type.name.underscore.pluralize)
      end
    else
      render :action => 'new'
    end
  rescue Exception => @exception    
    render :action => 'new'    
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

  end
  
  def update
    attrs = params[model_class.name.underscore]
    logger.debug "Updating Block: #{@block.inspect}"
    if @block.update_attributes(attrs)
      logger.debug "Block updated\n\n\n"
      flash[:notice] = "#{content_type_name.titleize} '#{@block.name}' was updated"
      redirect_to_first params[:_redirect_to], cms_url(:blocks, @block.class.name.underscore, :show, @block)
    else
      logger.warn "Errors: #{@block.errors.full_messages.join("\n")}"
      render :action => "edit"
    end
  rescue Exception => e
    if e.is_a?(ActiveRecord::StaleObjectError)
      @other_version = @block.class.find(@block.id) 
    else
      @exception = e
    end
    render :action => "edit"
  end

  def destroy
    do_command("deleted") { @block.destroy }
    redirect_to_first params[:_redirect_to], cms_content_library_url
  end

  def publish
    do_command("published") { @block.publish! }
    redirect_to_first params[:_redirect_to], cms_url(@block)
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
      @content_type_name ||= begin
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

    def set_toolbar_tab
      @toolbar_tab = :content_library
    end

    def determine_layout
      !params[:thickbox].blank? ? "cms/thickbox" : 'cms/content_library' 
    end

end
