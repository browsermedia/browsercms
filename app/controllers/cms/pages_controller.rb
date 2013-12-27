module Cms
  class PagesController < Cms::BaseController

    helper Cms::RenderingHelper

    before_filter :load_section, :only => [:new, :create]
    before_filter :load_page, :only => [:versions, :version, :revert_to, :destroy]
    before_filter :load_draft_page, :only => [:edit, :update]
    before_filter :hide_toolbar, :only => [:new, :create]
    before_action :strip_visibility_params, :only => [:create, :update]

    include Cms::PublishWorkflow

    def resource
      @page
    end

    def resource_param
      :page
    end

    def new
      @page = Page.new(:section => @section, :cacheable => true)
      if @section.child_nodes.count < 1
        @page.name = "Overview"
        @page.path = @section.path
      end
    end

    def show
      redirect_to Page.find(params[:id]).path
    end

    def create
      @page = Page.new(page_params)
      @page.section = @section
      if @page.save
        flash[:notice] = "Page was '#{@page.name}' created."
        redirect_to @page
      else
        render :action => "new"
      end
    end

    def update
      if @page.update(page_params)
        flash[:notice] = "Page was '#{@page.name}' updated."
        redirect_to @page
      else
        render :action => "edit"
      end
    rescue ActiveRecord::StaleObjectError => e
      @other_version = @page.class.find(@page.id)
      render :action => "edit"
    end

    def destroy
      respond_to do |format|
        if @page.destroy
          message = "Page '#{@page.name}' was deleted."
          format.html { flash[:notice] = message; redirect_to(sitemap_url) }
          format.json { render :json => {:success => true, :message => message} }
        else
          message = "Page '#{@page.name}' could not be deleted"
          format.html { flash[:error] = message; redirect_to(sitemap_url) }
          format.json { render :json => {:success => false, :message => message} }
        end
      end
    end

    #status actions
    {:publish => "published", :hide => "hidden", :archive => "archived"}.each do |status, verb|
      define_method status do
        if params[:page_ids]
          @pages = params[:page_ids].map { |id| Page.find(id) }
          raise Cms::Errors::AccessDenied unless @pages.all? { |page| current_user.able_to_edit?(page) }
          @pages.each { |page| page.send(status) }
          flash[:notice] = "#{params[:page_ids].size} pages #{verb}"
          redirect_to dashboard_url
        else
          load_page
          if @page.send(status)
            flash[:notice] = "Page '#{@page.name}' was #{verb}"
          end
          redirect_to @page.path
        end
      end
    end

    def version
      @page = @page.as_of_version(params[:version])
      @show_toolbar = true
      @show_page_toolbar = true
      @_connectors = @page.current_connectors
      @_connectables = @page.contents
      render :layout => @page.layout, :template => 'cms/content/show'
    end

    def revert_to
      if @page.revert_to(params[:version])
        flash[:notice] = "Page '#{@page.name}' was reverted to version #{params[:version]}"
      end

      respond_to do |format|
        format.html { redirect_to @page.path }
        format.js { render :template => 'cms/shared/show_notice' }
      end
    end

    protected


    private

    def page_params
      params.require(:page).permit(Cms::Page.permitted_params)
    end

    def strip_visibility_params
      unless current_user.able_to?(:publish_content)
        params[:page].delete :hidden
        params[:page].delete :archived
        params[:page].delete :visibility
      end
    end

    def load_page
      @page = Page.find(params[:id])
      raise Cms::Errors::AccessDenied unless current_user.able_to_edit?(@page)
    end

    def load_draft_page
      load_page
      @page = @page.as_of_draft_version
    end

    def load_section
      @section = Section.find(params[:section_id])
      raise Cms::Errors::AccessDenied unless current_user.able_to_edit?(@section)
    end

    def hide_toolbar
      @hide_page_toolbar = true
    end

    def load_templates
      @templates = PageTemplate.options
    end

  end
end