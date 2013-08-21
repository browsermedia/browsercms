module Cms
  class GroupsController < Cms::ResourceController
    include Cms::AdminTab

    check_permissions :administrate

    def index
      @groups = Group.includes(:group_type).paginate(:page => params[:page]).order(params[:order] || :name)
    end

    protected
    def after_create_url
      index_url
    end

    def after_update_url
      index_url
    end

    def set_menu_section
      @menu_section = 'groups'
    end

  end
end