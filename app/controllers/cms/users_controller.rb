module Cms
class UsersController < Cms::ResourceController
  layout 'cms/administration'

  check_permissions :administrate, :except => [:show, :change_password, :update_password]
  before_filter :only_self_or_administrator, :only => [:show, :change_password, :update_password]
  
  before_filter :set_menu_section
  after_filter :update_group_membership, :only => [:update, :create]
  after_filter :update_flash, :only => [ :update, :create ]
  
#  verify :method => :put, :only => [ :enable, :disable, :update_password ]
  
  def index
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
    
    query.collect! { |q| "(#{q})"}
    conditions = conditions.unshift(query.join(" AND "))
    per_page = params[:per_page] || 10
    
    @users = User.paginate(:page => params[:page], :per_page => per_page, :include => :user_group_memberships, :conditions => conditions, :order => "first_name, last_name, email")
  end

  def change_password
    user
  end

  def update_password
    if user.update_attributes(params[:user])
      flash[:notice] = "Password for '#{user.login}' was changed"
      redirect_to(current_user.able_to?(:administrate) ? users_path : user_path(user))
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
    def after_create_url
      index_url
    end

    def after_update_url
      index_url
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

    def update_group_membership
      @object.group_ids = params[:group_ids] unless params[:on_fail_action] == "change_password"
    end

  private
    def user
      @user ||= User.find(params[:id])
    end
    def set_menu_section
      @menu_section = 'users'
    end
    
    def only_self_or_administrator
      raise Cms::Errors::AccessDenied if !current_user.able_to?(:administrate) && params[:id].to_i != current_user.id
    end
end
end