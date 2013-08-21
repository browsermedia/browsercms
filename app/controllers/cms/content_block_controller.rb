require 'cms/category_type'
# This is not called directly
# This is the base class for other content blocks
module Cms
  class ContentBlockController < Cms::BaseController
    include Cms::ContentRenderingSupport

    layout 'cms/content_library'
    skip_filter :cms_access_required, :login_required
    before_filter :login_required, except: [:show_via_slug]
    before_filter :cms_access_required, except: [:show_via_slug]
    before_filter :set_toolbar_tab

    helper_method :block_form, :new_block_path, :block_path, :blocks_path, :content_type
    helper Cms::RenderingHelper

    def index
      load_blocks
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
          format.html {redirect_to_first params[:_redirect_to], blocks_path}
          format.json {render :json => {:success => true }}
        end

    end

    # Additional CMS Action

    def publish
      do_command("published") { @block.publish! }
      redirect_to_first params[:_redirect_to], block_path(@block)
    end

    def revert_to
      do_command("reverted to version #{params[:version]}") do
        revert_block(params[:version])
      end
      redirect_to_first params[:_redirect_to], block_path(@block)
    end

    def version
      load_block
      if params[:version]
        @block = @block.as_of_version(params[:version])
      end
      render "version"
    end

    def versions
      if model_class.versioned?
        load_block
      else
        render :text => "Not Implemented", :status => :not_implemented
      end
    end

    def usages
      load_block_draft
      @pages = @block.connected_pages.all(:order => 'name')
    end

    def new_button_path
      cms_new_path_for(content_type)
    end

    protected

    def assign_parent_if_specified
      if params[:parent]
        @block.parent_id = params[:parent]
      elsif @block.class.addressable?
        parent = Cms::Section.with_path(@block.class.path).first
        unless parent
          logger.warn "Creating default section for #{@block.display_name} in #{@block.class.path}."
          parent = Cms::Section.create(:name => @block.class.name.demodulize.pluralize,
                                       :parent => Cms::Section.root.first,
                                       :path => @block.class.path,
                                       :hidden => true,
                                       allow_groups: :all)
        end
        @block.parent_id = parent.id
      end
    end

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
      content_type.model_class_form_name
    end

    # methods for loading one or a collection of blocks

    def load_blocks
      options = {}
      if params[:section_id] && params[:section_id] != 'all'
        options[:include] = {:attachments => :section_node}
        options[:conditions] = ["#{Namespacing.prefix("section_nodes")}.ancestry = ?", Section.find(params[:section_id]).ancestry_path]
      end
      options[:page] = params[:page]
      options[:order] = model_class.default_order if model_class.respond_to?(:default_order)
      options[:order] = params[:order] unless params[:order].blank?

      scope = model_class.respond_to?(:list) ? model_class.list : model_class
      @blocks = scope.searchable? ? scope.search(params[:search]).paginate(options) : scope.paginate(options)
      check_permissions
    end

    def load_block
      @block = model_class.find(params[:id])
      check_permissions
    end

    def load_block_draft
      @block = model_class.find(params[:id])
      @block = @block.as_of_draft_version if model_class.versioned?
      check_permissions
    end

    # path related methods - available in the view as helpers

    def new_block_path(block, options={})
      cms_new_path_for(block, options)
    end

    def blocks_path(options={})
      cms_index_path_for(@content_type.model_class, options)
    end

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
      assign_parent_if_specified
      @block.save
    end

    def after_create_on_success
      block = @block.class.versioned? ? @block.draft : @block
      flash[:notice] = "#{content_type.display_name} '#{block.name}' was created"
      if @block.class.connectable? && @block.connected_page
        redirect_to @block.connected_page.path
      else
        redirect_to_first params[:_redirect_to], block_path(@block)
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
      redirect_to_first params[:_redirect_to], block_path(@block)
    end

    def after_update_on_failure
      render "edit"
    end

    def after_update_on_edit_conflict
      @other_version = @block.class.find(@block.id)
      after_update_on_failure
    end


    # methods for other actions

    # A "command" is when you want to perform an action on a content block
    # You pass a ruby block to this method, this calls it
    # and then sets a flash message based on success or failure
    def do_command(result)
      load_block
      if yield
        flash[:notice] = "#{content_type_name.demodulize.titleize} '#{@block.name}' was #{result}"
      else
        flash[:error] = "#{content_type_name.demodulize.titleize} '#{@block.name}' could not be #{result}"
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
        when "index", "show", "new", "create", "version", "versions", "usages"
          # Allow
        when "edit", "update", "inline"
          raise Cms::Errors::AccessDenied unless current_user.able_to_edit?(@block)
        when "destroy", "publish", "revert_to"
          raise Cms::Errors::AccessDenied unless current_user.able_to_publish?(@block)
        else
          raise Cms::Errors::AccessDenied
      end
    end

    # methods to setup the view

    def set_toolbar_tab
      @toolbar_tab = :content_library
    end

    private

    def render_block_in_main_container
      ensure_current_user_can_view(@block)
      @page = @block # page templates expect a @page attribute
      @content_block = @block # render.html.erb's expect a @content_block attribute
      render 'render_block_in_main_container', layout: @block.class.layout
    end

    def render_block_in_content_library
      render 'version'
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
      render "show", :layout => 'cms/block_editor'
    end
  end
end
