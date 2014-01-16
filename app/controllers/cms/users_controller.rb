module Cms
  class UsersController < Cms::ResourceController
    include Cms::AdminTab

    check_permissions :administrate, :except => [:change_password, :update_password]
    before_filter :only_self_or_administrator, :only => [:change_password, :update_password]
    after_filter :update_flash, :only => [:update]


    def index
      @have_external_users = Cms::ExternalUser.count > 0

      query, conditions = [], []

      unless params[:show_expired]
        query << "expires_at IS NULL OR expires_at >= ?"
        conditions << Time.now.utc
      end

      unless params[:key_word].blank?
        query << %w(login email first_name last_name).collect { |f| "lower(#{f}) LIKE lower(?)" }.join(" OR ")
        4.times { conditions << "%#{params[:key_word]}%" }
      end

      unless params[:group_id].to_i == 0
        query << "#{UserGroupMembership.table_name}.group_id = ?"
        conditions << params[:group_id]
      end

      query.collect! { |q| "(#{q})" }
      conditions = conditions.unshift(query.join(" AND "))
      per_page = params[:per_page] || 10

      page_num = params[:page] ? params[:page].to_i : 1
      @users = PersistentUser.where(conditions).paginate(page: page_num, per_page: per_page).includes(:user_group_memberships).references(:user_group_memberships).order("first_name, last_name, email")
    end

    def new
      @user = Cms::User.new
    end

    def create
      @user = Cms::User.new(cms_user_params)
      if @user.save
        flash[:notice] = "User '#{@user.login}' was created"
        redirect_to users_path
      else
        render :action => 'new'
      end
    end

    def change_password
      user
    end

    def update_password
      if user.update(cms_user_params)
        flash[:notice] = "Password for '#{user.login}' was changed"
        redirect_to(current_user.able_to?(:administrate) ? users_path : "/")
      else
        render :action => 'change_password'
      end
    end

    def disable
      begin
        user.disable!
        flash[:notice] = "User #{user.login} disabled"
      rescue Exception => e
        flash[:error] = e.message
      end
      redirect_to users_path
    end

    def enable
      user.enable!
      redirect_to users_path
    end

    protected

    def cms_user_params
      params.require("user").permit(Cms::User.permitted_params)
    end

    def after_create_url
      users_path
    end

    def after_update_url
      users_path
    end

    def update_flash
      if params[:on_fail_action] == "change_password"
        flash[:notice] = "Password for '#{@object.login}' changed"
      elsif params[:action] == "create"
        flash[:notice] = "User '#{@object.login}' was created"
      else
        flash[:notice] = "User '#{@object.login}' was updated"
      end
    end

    def resource_name
      'PersistentUser'
    end

    def variable_name
      'user'
    end

    private
    def user
      @user ||= PersistentUser.find(params[:id])
    end

    def set_menu_section
      @menu_section = 'users'
    end

    def only_self_or_administrator
      raise Cms::Errors::AccessDenied if !current_user.able_to?(:administrate) && params[:id].to_i != current_user.id
    end
  end
end