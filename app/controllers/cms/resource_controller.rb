#This is meant to be extended by other controller
#Provides basic Restful CRUD
module Cms
class ResourceController < Cms::BaseController

  def index
    instance_variable_set("@#{variable_name.pluralize}", resource.order(order_by_column))
  end

  def new
    instance_variable_set("@#{variable_name}", build_object)
  end

  def create
    @object = build_object(resource_params)
    if @object.save
      flash[:notice] = "#{resource_name.singularize.titleize} '#{object_name}' was created"
      redirect_to after_create_url
    else
      instance_variable_set("@#{variable_name}", @object)
      if (params[:on_fail_action])
        render :action => params[:on_fail_action]
      else
        render :action => 'new'
      end
    end
  end

  def show
    instance_variable_set("@#{variable_name}", resource.find(params[:id]))
  end

  def edit
    instance_variable_set("@#{variable_name}", resource.find(params[:id]))
  end

  def update
    @object = resource.find(params[:id])
    if @object.update(resource_params())
      flash[:notice] = "#{resource_name.singularize.titleize} '#{object_name}' was updated"
      redirect_to after_update_url
    else
      instance_variable_set("@#{variable_name}", @object)
      if (params[:on_fail_action])
        render :action => params[:on_fail_action]
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @object = resource.find(params[:id])
    if @object.destroy
      flash[:notice] = "#{resource_name.singularize.titleize} '#{object_name}' was deleted"
    end
    redirect_to index_url
  end

  protected

  # Returns the permitted parameters for the current resource, based on:
  # 1. The name of the resource (i.e. :page)
  # 2. The permitted parameters on the resource (i.e. Page.permitted_params)
  #
  # Resources can override permitted_params to add/remove fields as needed.
  def resource_params
    params.require("#{variable_name}").permit(resource.permitted_params)
  end


  def resource_name
    controller_name
  end

  def variable_name
    resource_name.singularize
  end

  def resource
    begin
      "Cms::#{resource_name.classify}".constantize
    rescue NameError
      resource_name.classify.constantize
    end
  end

  def build_object(params={})
    resource.new(params)
  end

  def object_name
    return nil unless @object
    @object.respond_to?(:name) ? @object.name : @object.to_s
  end

  def index_url
    engine_aware_path(resource)
  end

  def after_create_url
    show_url
  end

  def after_update_url
    show_url
  end

  def show_url
    @object
  end

  def order_by_column
    "name"
  end

  def new_template;
    'cms/blocks/new'
  end
  def edit_template;
    'cms/blocks/edit'
  end

end
end