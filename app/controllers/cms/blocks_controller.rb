class Cms::BlocksController < Cms::BaseController

  layout 'cms/content_library'

  before_filter :load_block, :only => [:show, :show_version, :edit, :destroy, :publish, :archive, :revert_to, :update]

  helper_method :model_name

  def index
    conditions = []
    unless params[:search].blank?
      conditions = ["#{model_class.table_name}.name like ?", "%#{params[:search]}%"]
      if params[:include_body]
        conditions[0] += " or #{model_class.table_name}.content like ?"
        conditions << "%#{params[:search]}%"
      end
    end

    if params[:section_id] and params[:section_id] != 'all'
      conditions[0] = conditions.empty? ? "sections.id = ?" : conditions[0] + " and sections.id = ?"
      conditions << params[:section_id]
      @blocks = model_class.find(:all, :order => "#{model_class.table_name}.name", :include => { :attachment => { :section_node => :section }}, :conditions => conditions)
    else
      @blocks = model_class.find(:all, :order => "#{model_class.table_name}.name", :conditions => conditions)
    end
  end

  def new
    @block = content_type.new_content(params[model_name])
    render :template => content_type.template_for_new, :layout => 'cms/application'
  end

  def create
    @block = content_type.new_content(params[model_name])
    @block.updated_by_user = current_user if @block.respond_to?(:updated_by_user)
    if @block.save
      flash[:notice] = "#{content_type.display_name} '#{@block.name}' was created"
      if @block.respond_to?(:connected_page) && !@block.connected_page.blank?
        redirect_to @block.connected_page.path
      else
        redirect_to_first params[:_redirect_to], cms_url(:blocks, content_type.name.underscore.pluralize)
      end
    else
      render :action => "new"
    end
  end

  def show_version
    if params[:version]
      @block = @block.as_of_version(params[:version])
    end
    render :action => 'show'
  end

  def revisions
    if model_class.respond_to?(:versioned_class_name)
      load_block
    else
      render :text => "Not Implemented", :status => :not_implemented
    end
  end

  def edit
    render :template => content_type.template_for_edit, :layout => 'cms/application'
  end
  
  def update
    attrs = params[model_name]
    attrs[:updated_by_user] = current_user if @block.respond_to?(:updated_by_user=)
    if @block.update_attributes(attrs)
      flash[:notice] = "#{model_name.titleize} '#{@block.name}' was updated"
      redirect_to_first params[:_redirect_to], cms_url(:blocks, @block.class.name.underscore, :show, @block)
    else
      render :action => "edit"
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
    do_command("published") { @block.publish(current_user) }
    redirect_to cms_url(@block)
  end

  def archive
    do_command("archived") { @block.archive(current_user) }
    redirect_to cms_url(@block)
  end

  def revert_to
    begin
      @block.revert_to(params[:version], current_user)
      flash[:notice] = "Reverted '#{@block.name}' to version #{params[:version]}"
    rescue Exception => e
      flash[:error] = "Could not revert '#{@block.name}': #{e}"
    end
    redirect_to cms_url(@block)
  end

  protected

    def model_class
      content_type.model_class
    end

    def content_type
      @content_type ||= ContentType.find_by_key(model_name)
    end

    def load_block
      @block = model_class.find(params[:id])
    end

    def do_command(result)
      if yield
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



end