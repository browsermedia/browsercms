# This is not called directly
# This is the base class for other content blocks
class Cms::ContentBlockController < Cms::BaseController
  
  layout :determine_layout
  
  before_filter :set_toolbar_tab
  
  helper_method :block_form, :new_block_path, :block_path, :blocks_path, :content_type
  
  # Basic REST Crud Action
  
  def index
    load_blocks
    render "#{template_directory}/index"
  end
  
  def show
    load_block_draft
    render "#{template_directory}/show"
  end
  
  def new
    build_block
    set_default_category
    render "#{template_directory}/new"
  end
  
  def create
    if create_block
      after_create_on_success
    else
      after_create_on_failure
    end
  rescue Exception => @exception
    after_create_on_error
  end
  
  def edit
    load_block_draft
    render "#{template_directory}/edit"
  end
  
  def update
    if update_block
      after_update_on_success
    else
      after_update_on_failure
    end
  rescue ActiveRecord::StaleObjectError => @exception
    after_update_on_edit_conflict
  rescue Exception => @exception
    after_update_on_error
  end
  
  def destroy
    do_command("deleted") { @block.destroy }
    redirect_to_first params[:_redirect_to], blocks_path
  end
  
  # Additional CMS Action
  
  def publish
    do_command("published") { @block.publish! }
    redirect_to_first params[:_redirect_to], block_path
  end
  
  def revert_to
    do_command("reverted to version #{params[:version]}") do
      revert_block(params[:version])
    end
    redirect_to_first params[:_redirect_to], block_path
  end
  
  def version
    load_block
    if params[:version]
      @block = @block.as_of_version(params[:version])
    end
    render "#{template_directory}/show"
  end
  
  def versions
    if model_class.versioned?
      load_block
      render "#{template_directory}/versions"
    else
      render :text => "Not Implemented", :status => :not_implemented
    end    
  end
    
  def usages
    load_block_draft
    @pages = @block.connected_pages.all(:order => 'name')
    render "#{template_directory}/usages"
  end
  
  protected
    # methods that are used to detemine what content block type we are dealing with

    def content_type_name
      self.class.name.sub(/Controller/,'').demodulize.singularize
    end

    def content_type
      @content_type ||= ContentType.find_by_key(content_type_name)
    end  

    def model_class
      content_type.model_class
    end
  
    def model_name
      model_class.name.underscore.to_sym
    end
  
    # methods for loading one or a collection of blocks
  
    def load_blocks
      options = {}
      if params[:section_id] && params[:section_id] != 'all'
        options[:include] = { :attachment => { :section_node => :section }} 
        options[:conditions] = ["sections.id = ?", params[:section_id]]
      end
      options[:page] = params[:page]    
      options[:order] = model_class.default_order if model_class.respond_to?(:default_order)
      options[:order] = params[:order] unless params[:order].blank?
      scope = model_class.respond_to?(:list) ? model_class.list : model_class
      @blocks = scope.searchable? ? scope.search(params[:search]).paginate(options) : scope.paginate(options)
    end
  
    def load_block
      @block = model_class.find(params[:id])
    end
  
    def load_block_draft
      load_block
      @block = @block.as_of_draft_version if model_class.versioned?
    end
  
    # path related methods - available in the view as helpers
  
    def new_block_path(options={})
      cms_new_url_for(@block, options)
    end
  
    def block_path(action=nil)
      path = [:cms, @block]
      action ? path.unshift(action) : path
    end
  
    def blocks_path(options={})
      cms_index_url_for(@block, options)
    end

    # This is the partial that will be used in the form
    def block_form
      @content_type.form
    end
  
    # new related methods
  
    def build_block
      @block = model_class.new(params[model_name])
    end

    def set_default_category
      if @last_block = model_class.last
        @block.category = @last_block.category if @block.respond_to?(:category=)
      end      
    end
    
    # create related methods
    
    def create_block
      build_block
      @block.save
    end

    def after_create_on_success
      block = @block.class.versioned? ? @block.draft : @block
      flash[:notice] = "#{content_type.display_name} '#{block.name}' was created"
      if @block.class.connectable? && @block.connected_page
        redirect_to @block.connected_page.path
      else
        redirect_to_first params[:_redirect_to], block_path
      end
    end

    def after_create_on_failure
      render "#{template_directory}/new"
    end

    def after_create_on_error
      logger.error "#{@exception.message}\n#{@exception.backtrace.join('\n')}"      
      after_create_on_failure
    end

    # update related methods
    def update_block
      load_block
      @block.update_attributes(params[model_name])
    end

    def after_update_on_success
      flash[:notice] = "#{content_type_name.titleize} '#{@block.name}' was updated"
      redirect_to_first params[:_redirect_to], block_path
    end

    def after_update_on_failure
      render "#{template_directory}/edit"
    end

    def after_update_on_edit_conflict
      @other_version = @block.class.find(@block.id)
      after_update_on_failure
    end

    def after_update_on_error
      logger.error "#{@exception.message}\n#{@exception.backtrace.join('\n')}"
      after_update_on_failure
    end

    # methods for other actions

    # A "command" is when you want to perform an action on a content block
    # You pass a ruby block to this method, this calls it
    # and then sets a flash message based on success or failure
    def do_command(result)
      load_block
      if yield
        flash[:notice] = "#{content_type_name.titleize} '#{@block.name}' was #{result}"
      else
        flash[:error] = "#{content_type_name.titleize} '#{@block.name}' could not be #{result}"
      end
    end

    def revert_block(to_version)
      begin
        @block.revert_to(to_version)
      rescue Exception => @exception
        logger.warn "Could not revert #{@block.inspect} to version #{to_version}"
        logger.warn "#{@exception.message}\n:#{@exception.backtrace.join("\n")}"
        false
      end
    end

    # methods to setup the view

    def set_toolbar_tab
      @toolbar_tab = :content_library
    end

    def determine_layout
      'cms/content_library'
    end

    def template_directory
      "cms/blocks"
    end

end