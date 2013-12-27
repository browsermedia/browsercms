require 'cms/category_type'
# This is not called directly
# This is the base class for other content blocks
module Cms
  class ContentBlockController < Cms::BaseController
    include Cms::ContentRenderingSupport

    allow_guests_to [:show_via_slug]

    helper_method :block_form, :content_type
    helper Cms::RenderingHelper
    helper do

      # Addressable content types don't allow for Mobile Optimized templates.
      def mobile_template_exists?(block)
        false
      end
    end
    include Cms::PublishWorkflow

    def index
      load_blocks
    end

    def bulk_update
      ids = params[:content_id] || []
      models = ids.collect do |id|
        model_class.find(id.to_i)
      end
      if params[:commit] == 'Delete'
        deleted = models.select do |m|
          m.destroy
        end
        flash[:notice] = "Deleted #{deleted.size} records."
      else
        # Need to do these one at a time since the code logic is more complex than single UPDATE.
        published = models.select do |m|
          m.publish!
        end

        flash[:notice] = "Published #{published.size} records."
      end

      redirect_to action: :index
    end

    # Getting content by its path  (i.e. /products/:slug)
    def show_via_slug
      @block = model_class.with_slug(params[:slug])
      unless @block
        raise Cms::Errors::ContentNotFound.new("No Content at #{model_class.calculate_path(params[:slug])}")
      end
      render_block_in_main_container
    end

    # Getting content by its id (i.e. /products/:id)
    # Logged in editors will get the editing frame.
    def show
      load_block_draft
      render_editing_frame_or_block_in_main_container
    end

    # Getting the content for the editing frame.
    def inline
      load_block_draft
      render_block_in_main_container
    end

    def new
      build_block
      set_default_category
    end

    def create
      if create_block
        after_create_on_success
      else
        after_create_on_failure
      end
    rescue Exception => @exception
      raise @exception if @exception.is_a?(Cms::Errors::AccessDenied)
      after_create_on_error
    end

    def edit
      load_block_draft
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
      raise @exception if @exception.is_a?(Cms::Errors::AccessDenied)
      after_update_on_error
    end

    def destroy
      do_command("deleted") { @block.destroy }
      respond_to do |format|
        format.html { redirect_to_first params[:_redirect_to], engine_aware_path(@block.class) }
        format.json { render :json => {:success => true} }
      end

    end

    # Additional CMS Action

    def publish
      do_command("published") { @block.publish! }
      redirect_to_first params[:_redirect_to], engine_aware_path(@block, nil)
    end

    def revert_to
      do_command("reverted to version #{params[:version]}") do
        revert_block(params[:version])
      end
      redirect_to_first params[:_redirect_to], engine_aware_path(@block, nil)
    end

    def version
      load_block
      if params[:version]
        @block = @block.as_of_version(params[:version])
      end
      render "show_in_isolation"
    end

    def versions
      if model_class.versioned?
        load_block
      else
        render :text => "Not Implemented", :status => :not_implemented
      end
    end

    def new_button_path
      new_engine_aware_path(content_type)
    end

    protected

    def content_type_name
      self.class.name.sub(/Controller/, '').singularize
    end

    def content_type
      @content_type ||= ContentType.find_by_key(content_type_name)
    end

    def model_class
      content_type.model_class
    end

    def model_form_name
      content_type.param_key
    end
    alias :resource_param :model_form_name

    def resource
      @block ||= find_block
    end

    # methods for loading one or a collection of blocks

    def load_blocks
      @search_filter = SearchFilter.build(params[:search_filter], model_class)

      options = {}

      options[:page] = params[:page]
      options[:order] = model_class.default_order if model_class.respond_to?(:default_order)
      options[:order] = params[:order] unless params[:order].blank?

      scope = model_class.respond_to?(:list) ? model_class.list : model_class
      if scope.searchable?
        scope = scope.search(@search_filter.term)
      end
      if params[:section_id] && model_class.respond_to?(:with_parent_id)
        scope = scope.with_parent_id(params[:section_id])
      end
      @total_number_of_items = scope.count
      @blocks = scope.paginate(options)
      check_permissions

    end

    def load_block
      find_block
      check_permissions
    end

    def find_block
      @block = model_class.find(params[:id])
    end

    def load_block_draft
      find_block
      @block = @block.as_of_draft_version if model_class.versioned?
      check_permissions
    end

    # path related methods - available in the view as helpers

    # This is the partial that will be used in the form
    def block_form
      @content_type.form
    end


    def build_block
      if params[model_form_name]
        @block = model_class.new(model_params)
      else
        # Need to make sure @block exists for form helpers to correctly generate paths
        @block = model_class.new unless @block
      end
      check_permissions
    end

    def set_default_category
      if @last_block = model_class.last
        @block.category = @last_block.category if @block.respond_to?(:category=)
      end
    end

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
        redirect_to_first params[:_redirect_to], engine_aware_path(@block)
      end
    end

    def after_create_on_failure
      render "new"
    end

    def after_create_on_error
      log_complete_stacktrace(@exception)
      after_create_on_failure
    end

    def after_update_on_error
      log_complete_stacktrace(@exception)
      after_update_on_failure
    end


    # update related methods
    def update_block
      load_block
      @block.update_attributes(model_params())
    end

    # Returns the parameters for the block to be saved.
    # Handles defaults as well as eventually 'strong_params'
    def model_params
      defaults = {"publish_on_save" => false}
      model_params = params[model_form_name]
      defaults.merge(model_params)
    end

    def after_update_on_success
      flash[:notice] = "#{content_type_name.demodulize.titleize} '#{@block.name}' was updated"
      redirect_to_first params[:_redirect_to], engine_aware_path(@block)
    end

    def after_update_on_failure
      render "edit"
    end

    def after_update_on_edit_conflict
      @other_version = @block.class.find(@block.id)
      after_update_on_failure
    end


    # A "command" is when you want to perform an action on a content block
    # You pass a ruby block to this method, this calls it
    # and then sets a flash message based on success or failure
    def do_command(result)
      load_block
      if yield
        flash[:notice] = "#{content_type_name.demodulize.titleize} '#{@block.name}' was #{result}" unless request.xhr?
      else
        flash[:error] = "#{content_type_name.demodulize.titleize} '#{@block.name}' could not be #{result}" unless request.xhr?
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

    # Use a "whitelist" approach to access to avoid mistakes
    # By default everyone can create new block and view them and their properties,
    # but blocks can only be modified based on the permissions of the pages they
    # are connected to.
    def check_permissions
      case action_name
        when "index", "show", "new", "create", "version", "versions"
          # Allow
        when "edit", "update", "inline"
          raise Cms::Errors::AccessDenied unless current_user.able_to_edit?(@block)
        when "destroy", "publish", "revert_to"
          raise Cms::Errors::AccessDenied unless current_user.able_to_publish?(@block)
        else
          raise Cms::Errors::AccessDenied
      end
    end

    private

    def render_block_in_main_container
      ensure_current_user_can_view(@block)
      show_content_as_page(@block)
      render 'render_block_in_main_container', layout: @block.class.layout
    end

    def render_block_in_content_library
      render 'show_in_isolation'
    end

    def render_editing_frame_or_block_in_main_container
      if @block.class.addressable?
        if current_user.able_to_edit?(@block)
          render_toolbar_and_iframe
        else
          render_block_in_main_container
        end
      else
        render_block_in_content_library
      end
    end

    def render_toolbar_and_iframe
      @page = @block
      @page_title = @block.page_title
      render "show", :layout => 'cms/page_editor'
    end
  end
end
