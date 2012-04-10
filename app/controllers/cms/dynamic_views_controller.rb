module Cms
  class DynamicViewsController < Cms::BaseController

    layout 'cms/administration'
    check_permissions :administrate

    before_filter :set_menu_section
    before_filter :load_view, :only => [:show, :edit, :update, :destroy]

    helper_method :dynamic_view_type

    def index
      @views = dynamic_view_type.paginate(:page => params[:page], :order => "name")
    end

    def new
      @view = dynamic_view_type.new_with_defaults
    end

    def create
      @view = dynamic_view_type.new(params[view_param_name])
      if @view.save
        flash[:notice] = "#{dynamic_view_type} '#{@view.name}' was created"
        redirect_to cms_index_path_for(dynamic_view_type)
      else
        render :action => "new"
      end
    end

    def show
      redirect_to [:edit, @view]
    end

    def update
      if @view.update_attributes(params[view_param_name])
        flash[:notice] = "#{dynamic_view_type} '#{@view.name}' was updated"
        redirect_to cms_index_path_for(dynamic_view_type)
      else
        render :action => "edit"
      end
    end

    def destroy
      @view.destroy
      flash[:notice] = "#{dynamic_view_type} '#{@view.name}' was deleted"
      redirect_to cms_index_path_for(dynamic_view_type)
    end

    protected

    def view_param_name
      dynamic_view_type.resource_collection_name
    end

    def dynamic_view_type
      @dynamic_view_type ||= begin
        url = request.path.sub(/\?.*/, '')
        type_name = url.split('/')[2].classify
        begin
          type = "Cms::#{type_name}".constantize
        rescue NameError
          type = type_name.constantize rescue nil
        end
        raise "Invalid Type" unless type.ancestors.include?(DynamicView)
        type
      end
    end

    def set_menu_section
      @menu_section = dynamic_view_type.name.underscore.pluralize
    end

    def load_view
      @view = dynamic_view_type.find(params[:id])
    end

  end
end
